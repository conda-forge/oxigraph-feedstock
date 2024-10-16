#!/usr/bin/env bash
set -eux

export OPENSSL_DIR=$PREFIX
export ROCKSDB_DIR=$PREFIX

rustc --version

mkdir -p "${CARGO_HOME}"

if [[ "${PKG_NAME}" == "oxigraph-server" ]]; then
    cd "${SRC_DIR}/cli"

    cargo-bundle-licenses \
        --format yaml \
        --output "${SRC_DIR}/THIRDPARTY.yml"

    cargo install \
        --locked \
        --no-track \
        --profile release \
        --root "${PREFIX}" \
        --path .
fi

if [[ "${PKG_NAME}" == "pyoxigraph" ]]; then
    cargo-bundle-licenses \
        --format yaml \
        --output "${SRC_DIR}/THIRDPARTY.yml"

    cd "${SRC_DIR}/python"

    if [[ "${target_platform}" == "${build_platform}" ]]; then
        export MATURIN_SETUP_ARGS="--features=rocksdb-pkg-config"
    fi
    "${PYTHON}" -m pip install -vv . --no-build-isolation --no-deps

    if [[ "${target_platform}" != "${build_platform}" ]]; then
        # workaround until cross-python is fixed
        rm "${BUILD_PREFIX}/bin/python"
        ln -sf "${PREFIX}/bin/python" "${BUILD_PREFIX}/bin/python"
    fi

    "${PYTHON}" generate_stubs.py pyoxigraph "${SP_DIR}/pyoxigraph/__init__.pyi"
    touch "${SP_DIR}/pyoxigraph/py.typed"
fi

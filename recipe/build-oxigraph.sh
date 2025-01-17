#!/usr/bin/env bash
set -eux

export OPENSSL_DIR="${PREFIX}"
export ROCKSDB_DIR="${PREFIX}"

rustc --version

mkdir -p "${CARGO_HOME}"

pushd "${SRC_DIR}/python"
    if [[ "${target_platform}" == "${build_platform}" ]]; then
        export MATURIN_SETUP_ARGS="--features=rocksdb-pkg-config"
    fi

    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

    "${PYTHON}" -m pip install . \
        -vv \
        --no-build-isolation \
        --no-deps \
        --disable-pip-version-check

    if [[ "${target_platform}" != "${build_platform}" ]]; then
        echo "will NOT generate stubs for ${target_platform}"
    else
        echo "WILL generate stubs on ${target_platform}"
        "${PYTHON}" generate_stubs.py pyoxigraph "${SP_DIR}/pyoxigraph/__init__.pyi"
        touch "${SP_DIR}/pyoxigraph/py.typed"
    fi
popd

if [[ "${SKIP_OXIGRAPH_SERVER}" == "0" ]]; then
    pushd "${SRC_DIR}/cli"
        cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

        cargo install \
            --locked \
            --no-track \
            --profile release \
            --root "${PREFIX}" \
            --path .
    popd
fi

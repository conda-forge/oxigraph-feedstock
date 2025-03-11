#!/usr/bin/env bash
set -eux

export OPENSSL_DIR="${PREFIX}"
export ROCKSDB_DIR="${PREFIX}"

rustc --version

mkdir -p "${CARGO_HOME}"

if [[ "${PKG_NAME}" == "oxigraph-server" ]]; then
    cd "${SRC_DIR}/cli"

    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

    cargo install \
        --locked \
        --no-track \
        --profile release \
        --root "${PREFIX}" \
        --path .
fi

if [[ "${PKG_NAME}" == "pyoxigraph" ]]; then
    cd "${SRC_DIR}/python"

    if [[ "${target_platform}" == "${build_platform}" ]]; then
        MATURIN_SETUP_ARGS="--features=rocksdb-pkg-config"
        export MATURIN_SETUP_ARGS
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
        "${PYTHON}" "${RECIPE_DIR}/build-stubs.py"
    fi
fi

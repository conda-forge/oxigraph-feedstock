#!/usr/bin/env bash
set -eux

export RUST_BACKTRACE=1

export OPENSSL_DIR=$PREFIX
export OPENSSL_NO_VENDOR=1
export ROCKSDB_DIR=$PREFIX

export CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG=true


if [[ "${target_platform}" == "osx-arm64" ]]; then
    echo "will NOT use pkgconfig for rocksdb on ${target_platform}"
elif [[ "${target_platform}" == "win-64" ]]; then
    echo "will NOT use pkgconfig for rocksdb on ${target_platform}"
else
    echo "WILL use pkgconfig for rocksdb on ${target_platform}"
    export MATURIN_SETUP_ARGS=--features=rocksdb-pkg-config
    export CARGO_FEATURE_ROCKSDB_PKG_CONFIG=1
fi

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
        --features rocksdb-pkg-config \
        --root "${PREFIX}" \
        --path .
fi

if [[ "${PKG_NAME}" == "pyoxigraph" ]]; then
    cd "${SRC_DIR}/python"

    cargo-bundle-licenses \
        --format yaml \
        --output "${SRC_DIR}/THIRDPARTY.yml"

    "${PYTHON}" -m pip install -vv . --no-build-isolation --no-deps

    "${PYTHON}" generate_stubs.py pyoxigraph "$SP_DIR/pyoxigraph/__init__.pyi"
    echo "" >> "$SP_DIR/pyoxigraph/py.typed"
    ls "$SP_DIR/pyoxigraph/__init__.pyi"
fi

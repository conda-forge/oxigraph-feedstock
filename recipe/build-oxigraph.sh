#!/usr/bin/env bash
set -eux

export RUST_BACKTRACE=1

export OPENSSL_DIR=$PREFIX
export OPENSSL_NO_VENDOR=1
export CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_DEBUG=true
export MATURIN_SETUP_ARGS=--features=rocksdb-pkg-config

rustc --version

mkdir -p "${CARGO_HOME}"

if [[ "${PKG_NAME}" == "oxigraph-server" ]]; then
    cd "${SRC_DIR}/server"

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

    if [ ${PY_VER} == "3.7" ] || [ ${PY_VER} == "3.8" ]; then
        echo "${PY_VER} does not have ast.unparse"
    else
        "${PYTHON}" generate_stubs.py pyoxigraph "$SP_DIR/pyoxigraph/__init__.pyi"
        echo "" >> "$SP_DIR/pyoxigraph/py.typed"
        ls "$SP_DIR/pyoxigraph/__init__.pyi"
    fi
fi

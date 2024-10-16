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

    if [[ "${target_platform}" == "osx-arm64" ]]; then
        maturin build --release --strip -m python/Cargo.toml -i "${PYTHON}" --target aarch64-apple-darwin
    elif [[ "${target_platform}" != "${build_platform}" ]]; then
      echo "Cross-compilation is not supported"
      exit
    else
        maturin build --release --strip -m python/Cargo.toml -i "${PYTHON}" --features rocksdb-pkg-config
    fi
    "${PYTHON}" -m pip install -vv --no-index --find-links=target/wheels/ pyoxigraph

    if [[ "${target_platform}" != "${build_platform}" ]]; then
        echo "will NOT generate stubs for ${target_platform}"
    else
        echo "WILL generate stubs on ${target_platform}"
        cd "${SRC_DIR}/python"
        "${PYTHON}" generate_stubs.py pyoxigraph "$SP_DIR/pyoxigraph/__init__.pyi"
        touch "$SP_DIR/pyoxigraph/py.typed"
    fi
fi

#!/usr/bin/env bash
set -eux

export CARGO_PROFILE_RELEASE_STRIP=symbols
export "OPENSSL_DIR=${PREFIX}"
export "ROCKSDB_DIR=${PREFIX}"

rustc --version

mkdir -p "${CARGO_HOME}"

if [[ "${PKG_NAME}" == "oxigraph-server" ]]; then
    cd "${SRC_DIR}/cli"

    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

    cargo auditable install \
        --locked \
        --no-track \
        --profile release \
        --root "${PREFIX}" \
        --path .
fi

if [[ "${PKG_NAME}" == "pyoxigraph" ]]; then
    "${PYTHON}" "${RECIPE_DIR}/build-pyoxigraph.py"
fi

#!/usr/bin/env bash
set -eux

export RUST_BACKTRACE=1

export CARGO_HOME="${BUILD_PREFIX}/cargo"
export PATH="${PATH}:${CARGO_HOME}/bin"

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER="${CC}"
export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER="${CC}"

rustc --version

mkdir -p "${CARGO_HOME}"

if [[ "${PKG_NAME}" == "oxigraph-server" ]]; then
    cd "${SRC_DIR}/server"
    cargo-bundle-licenses \
        --format yaml \
        --output "${SRC_DIR}/THIRDPARTY.yml"
    cargo install --locked --root "${PREFIX}" --path .
fi

if [[ "${PKG_NAME}" == "pyoxigraph" ]]; then
    cd "${SRC_DIR}/python"
    cargo-bundle-licenses \
        --format yaml \
        --output "${SRC_DIR}/THIRDPARTY.yml"
    maturin build --no-sdist --release --strip --manylinux off -i "${PYTHON}"
    "${PYTHON}" -m pip debug --verbose
    "${PYTHON}" -m pip install pyoxigraph -vv --no-index --find-links "${SRC_DIR}/target/wheels"
    if [ ${PY_VER} == "3.7" ] || [ ${PY_VER} == "3.8" ]; then
        echo "${PY_VER} does not have ast.unparse"
    else
        "${PYTHON}" generate_stubs.py pyoxigraph pyoxigraph.pyi --black
    fi
fi


rm -f "${PREFIX}/.crates.toml"
rm -f "${PREFIX}/.crates2.json"

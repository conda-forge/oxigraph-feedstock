#!/usr/bin/env bash
set -eux

export RUST_BACKTRACE=1

if test `uname` = "Darwin"; then
  COMPILER=clang
else
  COMPILER=gnu
fi

export CXXFLAGS="${CXXFLAGS} -std=c++11"

rustc --version

mkdir -p $CARGO_HOME

if [[ $PKG_NAME == "oxigraph-server" ]]; then
    cd $SRC_DIR/server
    cargo-bundle-licenses \
        --format yaml \
        --output ${SRC_DIR}/THIRDPARTY.yml
    cargo install --root $PREFIX --path .
fi

if [[ $PKG_NAME == "pyoxigraph" ]]; then
    cd $SRC_DIR/python
    cargo-bundle-licenses \
        --format yaml \
        --output ${SRC_DIR}/THIRDPARTY.yml
    maturin build --release -i $PYTHON
    $PYTHON -m pip install $SRC_DIR/target/wheels/*.whl
fi


rm -f "${PREFIX}/.crates.toml"
rm -f "${PREFIX}/.crates2.json"

@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set OPENSSL_NO_VENDOR=1
set CARGO_FEATURE_HTTP_CLIENT_NATIVE_TLS=1
set CARGO_FEATURE_HTTP_CLIENT_RUSTLS_NATIVE=0
set ROCKSDB_NO_PKG_CONFIG=1
set "OPENSSL_DIR=%LIBRARY_PREFIX%"
set "TEMP=%SRC_DIR%\tmpbuild_%PY_VER%"

mkdir "%TEMP%"

rustc --version

cd "%SRC_DIR%\python"

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 1

maturin build ^
    --release ^
    --strip ^
    -i "%PYTHON%" ^
    || exit 1

chcp 65001

"%PYTHON%" -m pip install ^
    pyoxigraph ^
    -vv ^
    --no-index ^
    --find-links "%SRC_DIR%\target\wheels" ^
    || exit 1

"%PYTHON%" generate_stubs.py pyoxigraph "%SP_DIR%\pyoxigraph\__init__.pyi" ^
   || exit 1

dir "%SP_DIR%\pyoxigraph\__init__.pyi" ^
   || exit 1

dir "%SP_DIR%\pyoxigraph\py.typed" ^
   || exit 1

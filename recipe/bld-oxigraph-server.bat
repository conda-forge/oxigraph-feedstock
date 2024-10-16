@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set OPENSSL_NO_VENDOR=1
set CARGO_FEATURE_HTTP_CLIENT_NATIVE_TLS=1
set CARGO_FEATURE_HTTP_CLIENT_RUSTLS_NATIVE=0
set "OPENSSL_DIR=%LIBRARY_PREFIX%"
set "ROCKSDB_DIR=%LIBRARY_PREFIX%"
set "TEMP=%SRC_DIR%\tmpbuild_%PY_VER%"

mkdir "%TEMP%"

rustc --version

cargo install ^
    --locked ^
    --no-track ^
    --path cli ^
    --profile release ^
    --root "%LIBRARY_PREFIX%" ^
    || exit 1

cd "%SRC_DIR%\cli"

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 1

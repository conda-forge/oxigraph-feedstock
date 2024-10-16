@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1

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

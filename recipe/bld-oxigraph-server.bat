@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP=%SRC_DIR%\tmpbuild_%PY_VER%

mkdir %TEMP%

rustc --version

cd %SRC_DIR%\server

cargo install --locked --root "%PREFIX%" --path . || goto :error

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY.yml ^
    || exit 1

del /F /Q "%PREFIX%\.crates2.json"
del /F /Q "%PREFIX%\.crates.toml"

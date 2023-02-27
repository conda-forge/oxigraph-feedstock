@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP="%SRC_DIR%\tmpbuild_%PY_VER%"

mkdir "%TEMP%"

rustc --version

cd "%SRC_DIR%\python"

maturin build --release --strip -i "%PYTHON%" ^
    || exit 1

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 1

chcp 65001

"%PYTHON%" -m pip install pyoxigraph -vv --no-index --find-links "%SRC_DIR%\target\wheels" ^
    || exit 1

:: doesn't have ast.unparse
if "%PY_VER%" == "3.7" goto :EOF
if "%PY_VER%" == "3.8" goto :EOF

"%PYTHON%" generate_stubs.py pyoxigraph pyoxigraph.pyi ^
   || exit 1

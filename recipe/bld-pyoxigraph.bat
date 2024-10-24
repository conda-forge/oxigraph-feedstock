@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set "OPENSSL_DIR=%LIBRARY_PREFIX%"

mkdir "%TEMP%"

rustc --version

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 1

cd "%SRC_DIR%\python"

%PYTHON% -m pip install . -vv --no-build-isolation --no-deps ^
   || exit 1

chcp 65001

"%PYTHON%" generate_stubs.py pyoxigraph "%SP_DIR%\pyoxigraph\__init__.pyi" ^
   || exit 1

copy /b NUL "%SP_DIR%\pyoxigraph\py.typed" ^
   || exit 1

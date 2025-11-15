@echo on

set PYTHONIOENCODING=UTF-8
set PYTHONUTF8=1
set "OPENSSL_DIR=%LIBRARY_PREFIX%"

mkdir "%TEMP%"

rustc --version

IF "%PKG_NAME%" == "oxigraph-server" (
   cd "%SRC_DIR%\server"

   cargo-bundle-licenses --format yaml --output THIRDPARTY.yml ^
      || exit 1

   cargo install ^
      --locked ^
      --no-track ^
      --profile release ^
      --root "%LIBRARY_PREFIX%" ^
      --path . ^
      || exit 1
)

IF "%PKG_NAME%" == "pyoxigraph" (
   cd "%SRC_DIR%\python"

   cargo-bundle-licenses --format yaml --output THIRDPARTY.yml ^
      || exit 1

   "%PYTHON%" -m pip install . ^
      -vv ^
      --no-build-isolation ^
      --no-deps ^
      --disable-pip-version-check ^
      || exit 1

   chcp 65001

   "%PYTHON%" generate_stubs.py pyoxigraph "%SP_DIR%\pyoxigraph\__init__.pyi" ^
      && copy /b NUL "%SP_DIR%\pyoxigraph\py.typed" ^
      || echo "failed to generate stubs, proceeeding anyway"
)

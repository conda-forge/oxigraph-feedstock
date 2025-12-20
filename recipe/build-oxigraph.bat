@echo on

set PYTHONIOENCODING=UTF-8
set PYTHONUTF8=1
set CARGO_PROFILE_RELEASE_STRIP=symbols
set "OPENSSL_DIR=%LIBRARY_PREFIX%"

mkdir "%TEMP%"

rustc --version

IF "%PKG_NAME%" == "oxigraph-server" (
   cd "%SRC_DIR%\cli"

   cargo-bundle-licenses --format yaml --output THIRDPARTY.yml ^
      || exit 2

   cargo install ^
      --locked ^
      --no-track ^
      --profile release ^
      --root "%LIBRARY_PREFIX%" ^
      --path . ^
      || exit 3
)

IF "%PKG_NAME%" == "pyoxigraph" (
   cd "%SRC_DIR%\python"

   cargo-bundle-licenses --format yaml --output THIRDPARTY.yml ^
      || exit 4

   "%PYTHON%" -m pip install . ^
      -vv ^
      --no-build-isolation ^
      --no-deps ^
      --disable-pip-version-check ^
      || exit 5

   chcp 65001

   "%PYTHON%" generate_stubs.py pyoxigraph "%SP_DIR%\pyoxigraph\__init__.pyi" ^
      || exit 6

   copy /b NUL "%SP_DIR%\pyoxigraph\py.typed" ^
      || exit 7

)

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
   "%PYTHON%" "%RECIPE_DIR%\build-pyoxigraph.py" || exit 4
)

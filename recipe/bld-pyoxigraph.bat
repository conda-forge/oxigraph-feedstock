@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP=%SRC_DIR%\tmpbuild_%PY_VER%

mkdir %TEMP%

rustc --version

cd %SRC_DIR%\python

maturin build --release -i %PYTHON% || exit 1

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY.yml ^
    || exit 1

chcp 65001

:: TODO: remove this: not sure what the TEMP was doing, but fails py310
:: %PYTHON% -m pip install %%w --build %TEMP% || exit 1

%PYTHON% -m pip install -vv --no-index --find-links=%SRC_DIR%\target\wheels pyoxigraph ^
    || exit 1

%PYTHON% generate_stubs.py pyoxigraph pyoxigraph.pyi --black ^
    || exit 1

del /F /Q "%PREFIX%\.crates2.json"
del /F /Q "%PREFIX%\.crates.toml"

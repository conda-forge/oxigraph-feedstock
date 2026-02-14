"""Portable logic for building pyoxigraph installation commands."""

import os
import sys
import json
from typing import Any
from pathlib import Path
from subprocess import call
import site


# flags
def ebool(var_name):
    return bool(json.loads(os.environ[var_name]))


IS_WIN = os.name == "nt"
IS_UNIX = not IS_WIN
IS_ABI3 = ebool("is_abi3")
PLAT_TGT = os.environ["target_platform"]
PLAT_BLD = os.environ["build_platform"]
IS_CROSS = PLAT_TGT != PLAT_BLD

# paths
PKG_NAME = os.environ["PKG_NAME"]
SRC_DIR = Path(os.environ["SRC_DIR"])
PY_SRC = SRC_DIR / "python"
SP_DIR = Path(site.getsitepackages()[-1])
PY_TYPED = SP_DIR / PKG_NAME / "py.typed"
GEN_STUBS_PY = PY_SRC / "generate_stubs.py"
SP_STUBS = SP_DIR / PKG_NAME / "__init__.pyi"
LICENSE_YML = PY_SRC / "THIRDPARTY.yml"

# commands
PY = Path(sys.executable)
DO_BUNDLE = ["cargo-bundle-licenses", "--format", "yaml", "--output", LICENSE_YML]
DO_INSTALL = [
    PY,
    "-m",
    "pip",
    "install",
    ".",
    "-vv",
    "--no-build-isolation",
    "--no-deps",
    "--disable-pip-version-check",
]
DO_STUBS = [PY, GEN_STUBS_PY, PKG_NAME, SP_STUBS]


def do(*args: Any) -> int:
    """Run a command, or quietly die trying."""
    str_args = map(str, args)
    print(">>>", *str_args)
    rc = call(args, cwd=str(PY_SRC))
    if rc:
        print("!!!", f"error {rc}", *str_args)
        sys.exit(rc)
    return rc


def feature(name: str, when: bool) -> list[str]:
    """Add a feature."""
    return ["--config-settings", f"build-args=--features={name}"] if when else []


def main() -> int:
    """Get licenses, install, and do typing."""
    do(*DO_BUNDLE)
    do(
        *DO_INSTALL,
        *feature("abi3", IS_ABI3),
        *feature("rocksdb-pkg-config", IS_UNIX and not IS_CROSS),
    )
    if IS_CROSS:
        print(f"... can't build {PLAT_TGT} stubs on {PLAT_BLD}")
    else:
        do(*DO_STUBS)
        PY_TYPED.touch()

    return 0


if __name__ == "__main__":
    sys.exit(main())

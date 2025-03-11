import site
import sys
from subprocess import call
from pathlib import Path

PKG_NAME = "pyoxigraph"
SP_DIR = Path(site.getsitepackages()[0]) / PKG_NAME
SP_STUBS = SP_DIR / "__init__.py"
SP_TYPED = SP_DIR / "py.typed"


def main() -> int:
    print("In", Path.cwd(), flush=True)
    print("... creating", SP_TYPED, flush=True)
    SP_TYPED.touch()
    print("... generating", SP_STUBS, flush=True)
    return call([sys.executable, "generate_stubs.py", PKG_NAME, SP_STUBS])


if __name__ == "__main__":
    sys.exit(main())

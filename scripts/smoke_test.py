"""
smoke_test.py — basic environment smoke test.

Verifies that required environment variables are loaded and that
key imports resolve correctly. Run via:
    uv run python scripts/smoke_test.py
"""

import sys

from dotenv import load_dotenv

load_dotenv()


def check_import(module: str) -> bool:
    try:
        __import__(module)
        print(f"  [OK]  {module}")
        return True
    except ImportError:
        print(f"  [SKIP] {module} not installed (optional dependency)")
        return False


def main() -> None:
    print("=== Smoke Test ===")

    print("\n-- Core imports --")
    check_import("dotenv")

    print("\n-- Optional imports --")
    check_import("snowflake.connector")
    check_import("ibm_db")

    print("\nPython version:", sys.version)
    print("\nSmoke test complete.")


if __name__ == "__main__":
    main()

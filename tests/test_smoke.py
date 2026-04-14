"""
test_smoke.py — pytest-style smoke tests for the productivity project.

Verifies that required imports resolve correctly and core helpers behave
as expected.  Run via:
    uv run pytest
"""

import sys

import pytest


def test_python_version() -> None:
    """Ensure we are running on Python 3.11+."""
    assert sys.version_info >= (3, 11), f"Python 3.11+ required, got {sys.version}"


def test_dotenv_importable() -> None:
    """python-dotenv must always be available (it is a core dependency)."""
    import dotenv  # noqa: F401


def test_check_import_returns_true_for_known_module() -> None:
    """smoke_test.check_import should return True for an importable module."""
    import importlib
    import sys

    # Ensure scripts/ is on the path so we can import smoke_test
    scripts_dir = str(__import__("pathlib").Path(__file__).parent.parent / "scripts")
    if scripts_dir not in sys.path:
        sys.path.insert(0, scripts_dir)

    smoke = importlib.import_module("smoke_test")
    assert smoke.check_import("dotenv") is True


def test_check_import_returns_false_for_missing_module() -> None:
    """smoke_test.check_import should return False for a non-existent module."""
    import importlib
    import sys

    scripts_dir = str(__import__("pathlib").Path(__file__).parent.parent / "scripts")
    if scripts_dir not in sys.path:
        sys.path.insert(0, scripts_dir)

    smoke = importlib.import_module("smoke_test")
    assert smoke.check_import("_this_module_does_not_exist_xyz") is False


@pytest.mark.parametrize("module", ["snowflake.connector", "ibm_db"])
def test_optional_imports_do_not_crash(module: str) -> None:
    """Optional heavy dependencies should either import cleanly or be absent — never crash."""
    try:
        __import__(module)
    except ImportError:
        pytest.skip(f"{module} not installed (optional dependency)")

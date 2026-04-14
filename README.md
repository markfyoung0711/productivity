# productivity
python productivity techniques

## Running tests

Tests are written with **pytest** and managed through `uv`.

```bash
# Install dev dependencies (includes pytest)
uv sync --extra dev

# Run the full test suite
uv run pytest

# Run with verbose output
uv run pytest -v
```

# 🧠 newsSweep Makefile

VENV=.venv
PYTHON=$(VENV)/bin/python
PIP=$(VENV)/bin/pip

.PHONY: help setup lint test clean run

help:
	@echo "newsSweep Makefile Commands:"
	@echo "  make setup     - Set up virtual environment and install dependencies"
	@echo "  make lint      - Run Bandit, Semgrep, and pre-commit checks"
	@echo "  make test      - Run tests (placeholder)"
	@echo "  make clean     - Remove build artifacts"
	@echo "  make run       - Run the CLI app (placeholder)"

setup:
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt || true

lint:
	pre-commit run --all-files || true
	bandit -r src || true
	semgrep --config auto src || true

test:
	@echo "🧪 Running tests (placeholder)..."
	pytest tests || true

clean:
	find . -type d -name "__pycache__" -exec rm -r {} +
	rm -rf .pytest_cache .mypy_cache .coverage dist build

run:
	@echo "🚀 Running newsSweep CLI (placeholder)..."
	$(PYTHON) src/cli/main.py || true

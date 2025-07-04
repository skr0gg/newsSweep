#!/bin/bash

set -e

# -------------------------------
# 🧠 newsSweep Bootstrap Script
# -------------------------------

PROJECT_DIR=~/newsSweep
VENV_DIR="$PROJECT_DIR/.venv"
PYTHON_BIN="$VENV_DIR/bin/python3"
OS="$(uname)"
CHECK_ONLY=false
SKIP_DOCKER=false
MINIMAL=false
HARDEN=false
DEV=false

# -------------------------------
# 🎛️ Argument Parsing
# -------------------------------
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --check) CHECK_ONLY=true ;;
        --no-docker) SKIP_DOCKER=true ;;
        --minimal) MINIMAL=true ;;
        --harden) HARDEN=true ;;
        --dev) DEV=true ;;
        *) echo "❌ Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# -------------------------------
# 🧪 Diagnostic Function
# -------------------------------
run_diagnostics() {
    echo "🔍 Running environment diagnostics..."
    echo "🐍 Python version: $($PYTHON_BIN --version 2>/dev/null || echo 'Not found')"
    echo "📦 pip: $($VENV_DIR/bin/pip --version 2>/dev/null || echo 'Not found')"
    echo "🔧 Git: $(git --version 2>/dev/null || echo 'Not found')"
    echo "🛠️  make: $(make --version 2>/dev/null | head -n 1 || echo 'Not found')"
    echo "🌐 curl: $(curl --version 2>/dev/null | head -n 1 || echo 'Not found')"
    echo "🔎 jq: $(jq --version 2>/dev/null || echo 'Not found')"
    echo "🐳 Docker: $(docker --version 2>/dev/null || echo 'Not found')"
    echo "🌍 Internet access: $(ping -c 1 github.com &>/dev/null && echo OK || echo Failed)"
    echo "📁 Project folders:"
    for dir in data_raw data_processed logs output config; do
        [ -d "$PROJECT_DIR/$dir" ] && echo "✅ $dir" || echo "❌ $dir missing"
    done
}

# -------------------------------
# 📦 Install System Packages
# -------------------------------
install_system_packages() {
    if [[ "$OS" == "Linux" ]]; then
        echo "📦 Installing Linux packages..."
        sudo apt update
        sudo apt install -y python3 python3-pip python3-venv git make curl jq
        if [ "$SKIP_DOCKER" = false ] && [ "$MINIMAL" = false ]; then
            sudo apt install -y docker.io
            if command -v systemctl &>/dev/null; then
                echo "🔧 Enabling Docker with systemd..."
                sudo systemctl enable docker || true
                sudo systemctl start docker || true
            else
                echo "⚠️  systemd not available. Start Docker manually if needed."
            fi
            sudo usermod -aG docker "$USER"
        fi
    elif [[ "$OS" == "Darwin" ]]; then
        echo "🍎 Installing macOS packages..."
        if ! command -v brew &>/dev/null; then
            echo "🔧 Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install python git make curl jq
        if [ "$SKIP_DOCKER" = false ] && [ "$MINIMAL" = false ]; then
            brew install --cask docker
            echo "⚠️  Start Docker.app manually on macOS."
        fi
    else
        echo "❌ Unsupported OS: $OS"
        exit 1
    fi
}

# -------------------------------
# 🐍 Python Environment Setup
# -------------------------------
setup_python_env() {
    echo "🐍 Setting up Python virtual environment..."
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    python3 -m venv .venv
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip
    pip install \
        requests feedparser aiohttp \
        transformers nltk spacy vaderSentiment \
        geopy shapely jinja2 markdown html2text \
        pre-commit bandit semgrep

    python -m nltk.downloader punkt vader_lexicon
    python -m spacy download en_core_web_sm

    if [ "$DEV" = true ]; then
        pip install pytest coverage black mypy
    fi

    if ! command -v gitleaks &>/dev/null; then
        echo "🔐 Installing gitleaks manually..."
        curl -sSL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_$(uname -s)_$(uname -m).tar.gz | tar -xz
        sudo mv gitleaks /usr/local/bin/
        echo "✅ gitleaks installed at /usr/local/bin/gitleaks"
    fi
}

# -------------------------------
# 📁 Project Structure
# -------------------------------
setup_project_structure() {
    echo "📁 Creating project directories..."
    mkdir -p data_raw data_processed logs output config
}

# -------------------------------
# 🔐 Git & Pre-commit
# -------------------------------
setup_git_and_hooks() {
    echo "🔧 Initializing Git and pre-commit hooks..."
    if [ ! -d .git ]; then
        git init
        echo ".venv/" >> .gitignore
        echo "__pycache__/" >> .gitignore
        echo "*.pyc" >> .gitignore
    fi

    cat <<YAML > .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: end-of-file-fixer
      - id: trailing-whitespace
  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
  - repo: https://github.com/returntocorp/semgrep
    rev: v1.64.0
    hooks:
      - id: semgrep
  - repo: https://github.com/zricethezav/gitleaks
    rev: v8.18.1
    hooks:
      - id: gitleaks
YAML

    pre-commit install
}

# -------------------------------
# 🛡️ Optional Linux Hardening
# -------------------------------
harden_linux() {
    echo "🛡️ Applying optional Linux hardening..."
    sudo apt install -y ufw apparmor auditd
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw enable
    sudo systemctl enable apparmor --now
    sudo systemctl enable auditd --now
    echo "✅ Hardening applied."
}

# -------------------------------
# 🚀 Main Execution
# -------------------------------
main() {
    if [ "$CHECK_ONLY" = true ]; then
        run_diagnostics
        exit 0
    fi

    install_system_packages
    setup_python_env
    setup_project_structure

    if [ "$MINIMAL" = false ]; then
        setup_git_and_hooks
    fi

    if [[ "$HARDEN" = true && "$OS" == "Linux" ]]; then
        harden_linux
    fi

    run_diagnostics

    echo "✅ newsSweep setup complete!"
    echo "👉 To activate your environment: source $VENV_DIR/bin/activate"
}

main

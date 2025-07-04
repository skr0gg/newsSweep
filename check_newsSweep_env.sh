#!/bin/bash

set -e

echo "🔍 Verifying newsSweep environment..."

# --- Directories ---
echo "📁 Checking directory structure..."
for dir in src/cli src/ingest src/geofence src/summarize src/output \
           data_raw data_processed logs output config tests; do
    [ -d "$dir" ] && echo "✅ $dir exists" || echo "❌ $dir missing"
done

# --- Key Files ---
echo "📄 Checking key files..."
for file in bootstrap_newsSweep.sh Makefile persona.ai sysArch.overview README.md; do
    [ -f "$file" ] && echo "✅ $file found" || echo "❌ $file missing"
done

# --- Python Environment ---
echo "🐍 Checking Python virtual environment..."
if [ -d ".venv" ]; then
    source .venv/bin/activate
    echo "✅ .venv activated"
    python --version
    pip list | grep -E 'transformers|nltk|spacy|vaderSentiment|requests' >/dev/null \
        && echo "✅ Core Python packages installed" \
        || echo "❌ Missing core Python packages"
else
    echo "❌ .venv not found"
fi

# --- Git Status ---
echo "🔧 Checking Git status..."
git rev-parse --is-inside-work-tree &>/dev/null && echo "✅ Git repo initialized" || echo "❌ Not a Git repo"
git remote -v | grep origin &>/dev/null && echo "✅ Remote origin set" || echo "❌ No remote origin"
git status --porcelain | grep . && echo "⚠️  Uncommitted changes present" || echo "✅ Working directory clean"

# --- Architecture File Check ---
echo "📐 Checking architecture overview..."
grep -q "Phase 1: High-Level Architecture" sysArch.overview && echo "✅ Architecture overview confirmed" || echo "❌ sysArch.overview missing or incomplete"

echo "✅ Environment check complete."

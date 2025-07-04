# 🧠 newsSweep

A CLI-first, open-source AI system that crawls, aggregates, and summarizes hyperlocal news and public data—entirely from your local machine.

---

## 🚀 Quick Start

```bash
chmod +x bootstrap_newsSweep.sh
./bootstrap_newsSweep.sh
```

Or use the Makefile:

```bash
make setup
make lint
make run
```

---

## 🧩 Architecture

```
[ CLI ]
   ↓
[ Ingestion ] → [ Geofencing ] → [ NLP Summarization ] → [ Output ]
```

- Modular Python system with CLI-first design
- NLP via HuggingFace Transformers, spaCy, NLTK, Vader
- Geofencing with geopy + shapely (~40 km radius around Slidell, LA)
- Outputs Markdown, HTML, or plaintext bulletins

---

## 🛠️ Requirements

- Python 3.11+
- Git, curl, jq, make
- Linux/macOS (WSL2 supported)
- No cloud dependencies or paid APIs

---

## 🔐 DevSecOps

- Pre-commit hooks: Bandit, Semgrep, Gitleaks
- Optional Linux hardening: AppArmor, UFW, auditd
- GitHub CLI for repo management

---

## 📁 Project Structure

```
newsSweep/
├── bootstrap_newsSweep.sh     # Full environment bootstrap
├── check_newsSweep_env.sh     # Diagnostic script
├── Makefile                   # CLI automation
├── persona.ai                 # AI system prompt
├── sysArch.overview           # Architecture overview
├── src/                       # Core modules
├── data_raw/                  # Raw crawled data
├── data_processed/            # Summarized output
├── output/                    # Final bulletins
├── logs/                      # Runtime logs
└── tests/                     # Unit tests
```

---

## 📚 License

MIT

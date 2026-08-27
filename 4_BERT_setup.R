# BERT setup script
# This script contains: Python selection, virtualenv creation, Python packages installations.
# One-time environment setup for Python + HuggingFace stack

library(reticulate)

# Create virtual environment (Python 3.10 explicitly!)
virtualenv_create(
  envname = "r-transformers",
  python = "C:/Users/HP/AppData/Local/Python/pythoncore-3.10-64/python.exe"
)

# Install Python packages
virtualenv_install(
  envname = "r-transformers",
  packages = c(
    "transformers",
    "torch",
    "sentence-transformers",
    "datasets",
    "accelerate"
  )
)
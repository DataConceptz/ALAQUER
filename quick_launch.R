#!/usr/bin/env Rscript

# ALAQUER Quick Launch Script
# This script quickly loads and launches ALAQUER

cat("\n")
cat("╔════════════════════════════════════════╗\n")
cat("║      ALAQUER Quick Launch              ║\n")
cat("╚════════════════════════════════════════╝\n")
cat("\n")

# Load all R files
cat("Loading ALAQUER...\n")

r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
for (file in r_files) {
  source(file, local = FALSE)
}

cat("✓ ALAQUER loaded successfully!\n\n")

# Check readiness
cat("Checking system status...\n")
is_ready <- check_alaquer_ready(verbose = TRUE)

cat("\n")

if (is_ready) {
  cat("Launching ALAQUER in 3 seconds...\n")
  Sys.sleep(3)
  launch_alaquer()
} else {
  cat("═══════════════════════════════════════════════════════════\n")
  cat("ALAQUER cannot start due to the issues above.\n")
  cat("\n")
  cat("Quick fixes:\n")
  cat("\n")
  cat("If Ollama is not connected:\n")
  cat("  1. Start Ollama: ollama serve\n")
  cat("  2. Pull a model: ollama pull llama2\n")
  cat("\n")
  cat("If packages are missing:\n")
  cat("  Run: install_alaquer_dependencies()\n")
  cat("\n")
  cat("═══════════════════════════════════════════════════════════\n")
}

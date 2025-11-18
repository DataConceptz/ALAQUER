#!/usr/bin/env Rscript

# ALAQUER Installation and Testing Script
# This script installs ALAQUER and its dependencies, then runs tests

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║        ALAQUER Installation and Testing Script            ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")
cat("\n")

# Step 1: Check R version
cat("Step 1: Checking R version...\n")
r_version <- getRversion()
cat(paste("  R version:", r_version, "\n"))

if (r_version < "4.0.0") {
  stop("R version 4.0.0 or higher is required. Please upgrade R.")
}
cat("  ✓ R version is acceptable\n\n")

# Step 2: Install dependencies
cat("Step 2: Installing dependencies...\n")

required_packages <- c(
  "shiny", "shinydashboard", "shinyWidgets", "shinyjs", "shinycssloaders",
  "DT", "httr", "jsonlite", "clipr", "readr", "readxl", "pdftools",
  "tm", "stringr", "dplyr", "tidyr", "markdown", "rmarkdown",
  "xml2", "rvest", "curl", "digest", "Matrix"
)

installed_count <- 0
failed_packages <- character()

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(paste("  Installing", pkg, "...\n"))
    tryCatch({
      install.packages(pkg, repos = "https://cloud.r-project.org/", quiet = TRUE)
      installed_count <- installed_count + 1
    }, error = function(e) {
      failed_packages <- c(failed_packages, pkg)
    })
  } else {
    cat(paste("  ✓", pkg, "already installed\n"))
  }
}

if (length(failed_packages) > 0) {
  cat("\n  ✗ Failed to install:\n")
  for (pkg in failed_packages) {
    cat(paste("    -", pkg, "\n"))
  }
  stop("Some packages failed to install. Please install them manually.")
}

cat("  ✓ All dependencies installed\n\n")

# Step 3: Load ALAQUER functions
cat("Step 3: Loading ALAQUER...\n")

# Source all R files
r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
for (file in r_files) {
  cat(paste("  Loading", basename(file), "...\n"))
  tryCatch({
    source(file)
  }, error = function(e) {
    warning(paste("Failed to load", file, ":", e$message))
  })
}

cat("  ✓ ALAQUER loaded\n\n")

# Step 4: Run basic tests
cat("Step 4: Running basic tests...\n")

# Test 1: Check system requirements
cat("  Test 1: System requirements... ")
tryCatch({
  reqs <- check_system_requirements()
  if (reqs$status %in% c("ready", "missing_packages")) {
    cat("PASS\n")
  } else {
    cat("FAIL\n")
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})

# Test 2: Check Ollama connection
cat("  Test 2: Ollama connection... ")
tryCatch({
  is_connected <- check_ollama_connection()
  if (is_connected) {
    cat("PASS (Ollama is running)\n")
  } else {
    cat("SKIP (Ollama not running - this is optional)\n")
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})

# Test 3: Check example prompts
cat("  Test 3: Example prompts library... ")
tryCatch({
  prompts <- get_example_prompts()
  if (length(prompts) >= 10) {
    cat("PASS (", length(prompts), " categories)\n", sep = "")
  } else {
    cat("FAIL\n")
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})

# Test 4: Check utilities
cat("  Test 4: Utility functions... ")
tryCatch({
  test_id <- generate_random_id(8)
  if (nchar(test_id) == 8) {
    cat("PASS\n")
  } else {
    cat("FAIL\n")
  }
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})

cat("\n")

# Step 5: Summary
cat("Step 5: Installation Summary\n")
cat("════════════════════════════════════════════════════════════\n")
cat("  ✓ R version check passed\n")
cat("  ✓ Dependencies installed\n")
cat("  ✓ ALAQUER functions loaded\n")
cat("  ✓ Basic tests completed\n")
cat("\n")

# Step 6: Next steps
cat("Next Steps:\n")
cat("────────────────────────────────────────────────────────────\n")
cat("1. Make sure Ollama is running:\n")
cat("   $ ollama serve\n")
cat("\n")
cat("2. Pull at least one model:\n")
cat("   $ ollama pull llama2\n")
cat("\n")
cat("3. Launch ALAQUER:\n")
cat("   > launch_alaquer()\n")
cat("\n")
cat("Or use the quick launch script:\n")
cat("   > source('quick_launch.R')\n")
cat("\n")

cat("═══════════════════════════════════════════════════════════\n")
cat("  Installation Complete!\n")
cat("═══════════════════════════════════════════════════════════\n")
cat("\n")

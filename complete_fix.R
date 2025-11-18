#!/usr/bin/env Rscript

# ALAQUER Complete Fix Script
# This script attempts to fix common installation and setup issues

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║           ALAQUER Complete Fix Script                     ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")
cat("\n")

# Step 1: Check and fix R version
cat("Step 1: Checking R version...\n")
r_version <- getRversion()
cat(paste("  Current R version:", r_version, "\n"))

if (r_version < "4.0.0") {
  cat("  ✗ R version is too old\n")
  cat("  Please upgrade R to version 4.0.0 or higher\n")
  cat("  Download from: https://www.r-project.org/\n")
  stop("R version upgrade required")
}
cat("  ✓ R version is acceptable\n\n")

# Step 2: Update package repositories
cat("Step 2: Updating package repositories...\n")
options(repos = c(CRAN = "https://cloud.r-project.org/"))
cat("  ✓ Repositories configured\n\n")

# Step 3: Install/Update required packages
cat("Step 3: Installing/Updating all required packages...\n")

required_packages <- c(
  # Core Shiny packages
  "shiny", "shinydashboard", "shinyWidgets", "shinyjs", "shinycssloaders",
  # Data handling
  "DT", "dplyr", "tidyr", "readr", "readxl",
  # HTTP and JSON
  "httr", "jsonlite", "curl",
  # Text processing
  "tm", "stringr", "markdown", "rmarkdown",
  # PDF and documents
  "pdftools",
  # Web scraping
  "xml2", "rvest",
  # Utilities
  "clipr", "digest", "Matrix"
)

install_count <- 0
update_count <- 0
fail_count <- 0

for (pkg in required_packages) {
  cat(paste("\n  Processing", pkg, "...\n"))

  # Check if installed
  is_installed <- requireNamespace(pkg, quietly = TRUE)

  if (!is_installed) {
    cat(paste("    Installing", pkg, "...\n"))
    result <- tryCatch({
      install.packages(pkg, dependencies = TRUE)
      install_count <- install_count + 1
      TRUE
    }, error = function(e) {
      cat(paste("    ✗ Failed:", e$message, "\n"))
      fail_count <- fail_count + 1
      FALSE
    })
  } else {
    cat(paste("    ✓", pkg, "already installed\n"))

    # Try to update
    tryCatch({
      update.packages(oldPkgs = pkg, ask = FALSE)
      update_count <- update_count + 1
    }, error = function(e) {
      # Ignore update errors
    })
  }
}

cat("\n  Summary:\n")
cat(paste("    Installed:", install_count, "\n"))
cat(paste("    Updated:", update_count, "\n"))
cat(paste("    Failed:", fail_count, "\n"))

if (fail_count > 0) {
  cat("\n  ⚠ Some packages failed to install\n")
  cat("  Try installing them manually or check your internet connection\n")
}

cat("  ✓ Package installation complete\n\n")

# Step 4: Load ALAQUER
cat("Step 4: Loading ALAQUER functions...\n")

if (!dir.exists("R")) {
  stop("R directory not found. Make sure you're in the ALAQUER directory")
}

r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
loaded_count <- 0
load_errors <- character()

for (file in r_files) {
  result <- tryCatch({
    source(file, local = FALSE)
    loaded_count <- loaded_count + 1
    TRUE
  }, error = function(e) {
    load_errors <- c(load_errors, basename(file))
    FALSE
  })
}

cat(paste("  Loaded", loaded_count, "of", length(r_files), "files\n"))

if (length(load_errors) > 0) {
  cat("  ✗ Failed to load:\n")
  for (file in load_errors) {
    cat(paste("    -", file, "\n"))
  }
}

cat("  ✓ ALAQUER functions loaded\n\n")

# Step 5: Verify Ollama
cat("Step 5: Checking Ollama...\n")

ollama_connected <- tryCatch({
  check_ollama_connection("http://localhost:11434")
}, error = function(e) {
  FALSE
})

if (ollama_connected) {
  cat("  ✓ Ollama is running\n")

  # Check for models
  models <- tryCatch({
    get_ollama_models("http://localhost:11434")
  }, error = function(e) {
    NULL
  })

  if (!is.null(models) && length(models) > 0) {
    cat(paste("  ✓ Found", length(models), "Ollama models:\n"))
    for (model in models) {
      cat(paste("    -", model, "\n"))
    }
  } else {
    cat("  ⚠ No Ollama models found\n")
    cat("  Install a model with: ollama pull llama2\n")
  }
} else {
  cat("  ✗ Ollama is not running\n")
  cat("\n  To start Ollama:\n")
  cat("    1. Install Ollama from: https://ollama.ai/\n")
  cat("    2. Start the service: ollama serve\n")
  cat("    3. Pull a model: ollama pull llama2\n")
}

cat("\n")

# Step 6: Run system check
cat("Step 6: Running full system check...\n\n")

tryCatch({
  check_alaquer_ready(verbose = TRUE)
}, error = function(e) {
  cat("  Error during system check:", e$message, "\n")
})

# Final summary
cat("\n")
cat("═══════════════════════════════════════════════════════════\n")
cat("  Fix Script Complete!\n")
cat("═══════════════════════════════════════════════════════════\n")
cat("\n")

if (fail_count == 0 && ollama_connected) {
  cat("✓ Everything looks good!\n")
  cat("\n")
  cat("You can now launch ALAQUER:\n")
  cat("  > launch_alaquer()\n")
  cat("\n")
  cat("Or use quick launch:\n")
  cat("  > source('quick_launch.R')\n")
} else {
  cat("⚠ Some issues remain:\n\n")

  if (fail_count > 0) {
    cat("  - Some packages failed to install\n")
    cat("    Try: install_alaquer_dependencies()\n\n")
  }

  if (!ollama_connected) {
    cat("  - Ollama is not connected\n")
    cat("    Follow the instructions above to set up Ollama\n\n")
  }

  cat("After fixing these issues, try launching again:\n")
  cat("  > source('quick_launch.R')\n")
}

cat("\n")

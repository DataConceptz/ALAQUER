#' ALAQUER RStudio Addin
#'
#' This function is called when ALAQUER is launched from RStudio's Addins menu.
#' It provides the same functionality as launch_alaquer() but is optimized for
#' RStudio integration.
#'
#' @return None. Launches the ALAQUER Shiny application
#' @keywords internal
#' @export
alaquer_addin <- function() {

  # Display startup message in RStudio console
  message("\n╔════════════════════════════════════════╗")
  message("║       Launching ALAQUER Addin          ║")
  message("╚════════════════════════════════════════╝\n")

  # Check if running in RStudio
  if (!rstudioapi::isAvailable()) {
    message("Note: ALAQUER works best in RStudio but can run in any R environment.")
  }

  # Quick system check
  message("Checking system status...")

  # Check Ollama connection
  ollama_ok <- check_ollama_connection()

  if (ollama_ok) {
    message("✓ Ollama connection: OK")

    # Check for models
    models <- get_ollama_models()
    if (!is.null(models) && length(models) > 0) {
      message(paste("✓ Found", length(models), "Ollama model(s)"))
    } else {
      message("⚠ No Ollama models found")
      message("  Install a model with: ollama pull llama2")
    }
  } else {
    message("✗ Ollama connection: Failed")
    message("  Make sure Ollama is running:")
    message("  1. Start Ollama: ollama serve")
    message("  2. Pull a model: ollama pull llama2")
    message("\nContinuing anyway - you can configure Ollama later...")
  }

  message("\nStarting ALAQUER application...")
  message("Your browser will open in a moment.\n")

  # Launch the application
  # Use launch_alaquer with default settings optimized for RStudio
  tryCatch({
    launch_alaquer(
      host = "127.0.0.1",
      port = NULL,  # Let Shiny choose an available port
      launch.browser = TRUE,
      ollama_host = "http://localhost:11434"
    )
  }, error = function(e) {
    message("\n✗ Error launching ALAQUER:")
    message(paste("  ", e$message))
    message("\nTroubleshooting:")
    message("  1. Check that all dependencies are installed")
    message("  2. Run: install_alaquer_dependencies()")
    message("  3. Try: source('quick_launch.R') from ALAQUER directory")
  })
}

#' Check if RStudio API is Available
#'
#' Internal helper to check RStudio availability
#'
#' @return Logical. TRUE if RStudio API is available
#' @keywords internal
is_rstudio_available <- function() {
  requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()
}

#' Get ALAQUER Addin Info
#'
#' Display information about the ALAQUER RStudio addin
#'
#' @return Invisible NULL. Prints information to console
#' @export
#' @examples
#' \dontrun{
#' alaquer_addin_info()
#' }
alaquer_addin_info <- function() {
  cat("\n")
  cat("╔════════════════════════════════════════════════════════════╗\n")
  cat("║                    ALAQUER Addin                           ║\n")
  cat("╚════════════════════════════════════════════════════════════╝\n")
  cat("\n")
  cat("ALAQUER is available as both an R package and RStudio addin.\n")
  cat("\n")
  cat("Launch Methods:\n")
  cat("───────────────────────────────────────────────────────────\n")
  cat("\n")
  cat("1. RStudio Addins Menu (Recommended for RStudio users):\n")
  cat("   • Click: Addins > ALAQUER - AI Assistant\n")
  cat("\n")
  cat("2. R Function Call (Works everywhere):\n")
  cat("   • Run: launch_alaquer()\n")
  cat("\n")
  cat("3. Quick Launch Script:\n")
  cat("   • Run: source('quick_launch.R')\n")
  cat("\n")
  cat("Features:\n")
  cat("───────────────────────────────────────────────────────────\n")
  cat("  ✓ ChatGPT-style interface for Ollama models\n")
  cat("  ✓ Super RAG with semantic chunking\n")
  cat("  ✓ AI-powered prompt engineering\n")
  cat("  ✓ Online search integration\n")
  cat("  ✓ 150+ professional example prompts\n")
  cat("  ✓ Advanced response processing\n")
  cat("\n")
  cat("Requirements:\n")
  cat("───────────────────────────────────────────────────────────\n")
  cat("  • R >= 4.0.0\n")
  cat("  • Ollama installed and running\n")
  cat("  • At least one Ollama model installed\n")
  cat("\n")
  cat("Quick Setup:\n")
  cat("───────────────────────────────────────────────────────────\n")
  cat("  1. Start Ollama:    ollama serve\n")
  cat("  2. Pull a model:    ollama pull llama2\n")
  cat("  3. Launch ALAQUER:  Use Addins menu or launch_alaquer()\n")
  cat("\n")
  cat("For more information: ?launch_alaquer or ?ALAQUER\n")
  cat("\n")

  invisible(NULL)
}

#' Launch ALAQUER Application
#'
#' Start the ALAQUER Shiny application
#'
#' @param host Character string. Host to run on (default: "127.0.0.1")
#' @param port Integer. Port to run on (default: NULL, will choose automatically)
#' @param launch.browser Logical. Whether to launch browser automatically (default: TRUE)
#' @param ollama_host Character string. Ollama host URL (default: "http://localhost:11434")
#' @return None. Starts the Shiny application
#' @export
#' @examples
#' \dontrun{
#' # Launch with default settings
#' launch_alaquer()
#'
#' # Launch with custom configuration
#' launch_alaquer(
#'   port = 3838,
#'   ollama_host = "http://localhost:11434",
#'   launch.browser = TRUE
#' )
#' }
launch_alaquer <- function(host = "127.0.0.1",
                          port = NULL,
                          launch.browser = TRUE,
                          ollama_host = "http://localhost:11434") {

  # Check system requirements
  message("Checking system requirements...")
  reqs <- check_system_requirements()

  if (reqs$status == "r_version_too_old") {
    stop("R version too old. Please upgrade to R >= 4.0.0")
  }

  if (reqs$status == "missing_packages") {
    missing <- names(reqs$packages)[!sapply(reqs$packages, function(p) p$installed)]
    warning(paste("Some packages are missing:", paste(missing, collapse = ", ")))
    message("Attempting to install missing packages...")

    for (pkg in missing) {
      tryCatch({
        install.packages(pkg)
      }, error = function(e) {
        warning(paste("Failed to install", pkg))
      })
    }
  }

  # Check Ollama connection
  if (!check_ollama_connection(ollama_host)) {
    warning(paste(
      "Cannot connect to Ollama at", ollama_host, "\n",
      "Please make sure Ollama is running.\n",
      "You can start it with: ollama serve"
    ))
  } else {
    message("Successfully connected to Ollama!")
  }

  # Create UI
  ui <- create_alaquer_ui(ollama_host = ollama_host)

  # Create Server
  server <- function(input, output, session) {
    create_alaquer_server(input, output, session, ollama_host = ollama_host)
  }

  # Create and launch app
  app <- shiny::shinyApp(ui = ui, server = server)

  message("\n==============================================")
  message("  Starting ALAQUER")
  message("  Advanced Language AI Query User Experience")
  message("==============================================\n")

  if (!is.null(port)) {
    message(paste("Server running on: http://", host, ":", port, sep = ""))
  }

  message("\nPress Ctrl+C to stop the server\n")

  # Run app
  shiny::runApp(
    app,
    host = host,
    port = port,
    launch.browser = launch.browser
  )
}

#' Check if ALAQUER is Ready
#'
#' Verify that ALAQUER can run successfully
#'
#' @param ollama_host Character string. Ollama host to check (default: "http://localhost:11434")
#' @param verbose Logical. Print detailed information (default: TRUE)
#' @return Logical. TRUE if ready, FALSE otherwise
#' @export
#' @examples
#' \dontrun{
#' # Check if ready to run
#' is_ready <- check_alaquer_ready()
#'
#' if (is_ready) {
#'   launch_alaquer()
#' }
#' }
check_alaquer_ready <- function(ollama_host = "http://localhost:11434", verbose = TRUE) {

  ready <- TRUE

  if (verbose) cat("Checking ALAQUER readiness...\n\n")

  # Check R version
  if (verbose) cat("1. Checking R version... ")
  r_ok <- getRversion() >= "4.0.0"
  if (verbose) cat(ifelse(r_ok, "OK\n", "FAILED (need R >= 4.0.0)\n"))
  ready <- ready && r_ok

  # Check required packages
  if (verbose) cat("2. Checking required packages... ")
  required_pkgs <- c("shiny", "shinydashboard", "httr", "jsonlite")
  pkgs_ok <- all(sapply(required_pkgs, requireNamespace, quietly = TRUE))
  if (verbose) cat(ifelse(pkgs_ok, "OK\n", "FAILED (missing packages)\n"))
  ready <- ready && pkgs_ok

  # Check Ollama connection
  if (verbose) cat("3. Checking Ollama connection... ")
  ollama_ok <- check_ollama_connection(ollama_host)
  if (verbose) cat(ifelse(ollama_ok, "OK\n", "FAILED (Ollama not running)\n"))

  # Check Ollama models
  if (ollama_ok) {
    if (verbose) cat("4. Checking Ollama models... ")
    models <- get_ollama_models(ollama_host)
    models_ok <- !is.null(models) && length(models) > 0
    if (verbose) {
      if (models_ok) {
        cat(paste0("OK (", length(models), " models available)\n"))
      } else {
        cat("WARNING (no models installed)\n")
      }
    }
  }

  if (verbose) {
    cat("\n")
    if (ready) {
      cat("✓ ALAQUER is ready to launch!\n")
      cat("  Run: launch_alaquer()\n")
    } else {
      cat("✗ ALAQUER is not ready\n")
      cat("  Please resolve the issues above\n")
    }
  }

  return(ready)
}

#' Install ALAQUER Dependencies
#'
#' Install all required dependencies for ALAQUER
#'
#' @param upgrade Logical. Whether to upgrade existing packages (default: FALSE)
#' @return Logical. TRUE if successful, FALSE otherwise
#' @export
#' @examples
#' \dontrun{
#' # Install all dependencies
#' install_alaquer_dependencies()
#' }
install_alaquer_dependencies <- function(upgrade = FALSE) {

  required_packages <- c(
    "shiny", "shinydashboard", "shinyWidgets", "shinyjs", "shinycssloaders",
    "DT", "httr", "jsonlite", "clipr", "readr", "readxl", "pdftools",
    "tm", "stringr", "dplyr", "tidyr", "markdown", "rmarkdown",
    "xml2", "rvest", "curl", "digest", "Matrix"
  )

  message("Installing ALAQUER dependencies...\n")

  failed <- character()
  success_count <- 0

  for (pkg in required_packages) {
    cat(sprintf("Installing %-20s ... ", pkg))

    # Check if already installed
    if (!upgrade && requireNamespace(pkg, quietly = TRUE)) {
      cat("already installed\n")
      success_count <- success_count + 1
      next
    }

    # Install package
    result <- tryCatch({
      install.packages(pkg, dependencies = TRUE, quiet = TRUE)
      TRUE
    }, error = function(e) {
      FALSE
    })

    if (result && requireNamespace(pkg, quietly = TRUE)) {
      cat("OK\n")
      success_count <- success_count + 1
    } else {
      cat("FAILED\n")
      failed <- c(failed, pkg)
    }
  }

  message(paste("\n", success_count, "/", length(required_packages), "packages installed successfully"))

  if (length(failed) > 0) {
    message("\nFailed to install:")
    for (pkg in failed) {
      message(paste("  -", pkg))
    }
    message("\nPlease try installing these packages manually:")
    message(paste0('  install.packages(c("', paste(failed, collapse = '", "'), '"))'))
    return(FALSE)
  }

  message("\n✓ All dependencies installed successfully!")
  return(TRUE)
}

#' Get ALAQUER Version
#'
#' Get the version of ALAQUER package
#'
#' @return Character string with version number
#' @export
get_alaquer_version <- function() {
  return("3.0.0")
}

#' Print ALAQUER Welcome Message
#'
#' Print welcome message with package information
#'
#' @export
alaquer_welcome <- function() {
  cat("\n")
  cat("╔════════════════════════════════════════════════════════════╗\n")
  cat("║                                                            ║\n")
  cat("║                        ALAQUER                             ║\n")
  cat("║    Advanced Language AI Query User Experience in R        ║\n")
  cat("║                                                            ║\n")
  cat("╚════════════════════════════════════════════════════════════╝\n")
  cat("\n")
  cat(paste("Version:", get_alaquer_version(), "\n"))
  cat("\n")
  cat("Features:\n")
  cat("  ✓ ChatGPT-style interface for Ollama models\n")
  cat("  ✓ Super RAG with semantic chunking\n")
  cat("  ✓ AI-powered prompt engineering\n")
  cat("  ✓ Online search integration\n")
  cat("  ✓ Advanced response processing\n")
  cat("  ✓ 150+ professional example prompts\n")
  cat("\n")
  cat("Quick Start:\n")
  cat("  1. Make sure Ollama is running: ollama serve\n")
  cat("  2. Launch ALAQUER: launch_alaquer()\n")
  cat("\n")
  cat("For help: ?launch_alaquer\n")
  cat("\n")
}

#' Display ALAQUER Package Startup Message
#'
#' @param libname Library name
#' @param pkgname Package name
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "\n╔════════════════════════════════════════╗\n",
    "║          ALAQUER v", get_alaquer_version(), "          ║\n",
    "╚════════════════════════════════════════╝\n",
    "\nAdvanced Language AI Query User Experience in R\n",
    "\nType 'alaquer_welcome()' for more information\n",
    "Type 'launch_alaquer()' to start the application\n"
  )
}

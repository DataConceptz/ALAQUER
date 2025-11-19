#' Session Persistence System
#'
#' Save and restore user sessions including settings, preferences, and state
#'
#' @name session_persistence
NULL

#' Save Session State
#'
#' Save complete session state to disk
#'
#' @param session_data List. Session data to save
#' @param session_name Character string. Optional session name
#' @param directory Character string. Storage directory
#' @return Character string with filepath, or NULL if error
#' @export
save_session <- function(session_data,
                        session_name = NULL,
                        directory = "~/.alaquer/sessions") {

  dir <- path.expand(directory)
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  if (is.null(session_name)) {
    session_name <- format(Sys.time(), "session_%Y%m%d_%H%M%S")
  }

  # Ensure .rds extension
  if (!grepl("\\.rds$", session_name)) {
    session_name <- paste0(session_name, ".rds")
  }

  filepath <- file.path(dir, session_name)

  # Add metadata
  session_with_meta <- list(
    data = session_data,
    saved_at = Sys.time(),
    alaquer_version = get_alaquer_version()
  )

  tryCatch({
    saveRDS(session_with_meta, filepath)
    message(paste("Session saved:", filepath))
    return(filepath)
  }, error = function(e) {
    warning(paste("Error saving session:", e$message))
    return(NULL)
  })
}

#' Load Session State
#'
#' Load a saved session
#'
#' @param filepath Character string. Path to session file
#' @return List with session data, or NULL if error
#' @export
load_session <- function(filepath) {

  filepath <- path.expand(filepath)

  if (!file.exists(filepath)) {
    warning(paste("Session file not found:", filepath))
    return(NULL)
  }

  tryCatch({
    session_with_meta <- readRDS(filepath)

    # Check version compatibility
    if (!is.null(session_with_meta$alaquer_version)) {
      message(paste("Loading session from ALAQUER version",
                   session_with_meta$alaquer_version))
    }

    return(session_with_meta$data)

  }, error = function(e) {
    warning(paste("Error loading session:", e$message))
    return(NULL)
  })
}

#' List Saved Sessions
#'
#' Get list of all saved sessions
#'
#' @param directory Character string. Storage directory
#' @return Data frame with session info
#' @export
list_sessions <- function(directory = "~/.alaquer/sessions") {

  dir <- path.expand(directory)

  if (!dir.exists(dir)) {
    return(data.frame(
      filename = character(),
      path = character(),
      size = numeric(),
      modified = character()
    ))
  }

  files <- list.files(dir, pattern = "\\.rds$", full.names = TRUE)

  if (length(files) == 0) {
    return(data.frame(
      filename = character(),
      path = character(),
      size = numeric(),
      modified = character()
    ))
  }

  file_info <- file.info(files)

  data.frame(
    filename = basename(files),
    path = files,
    size = file_info$size,
    modified = as.character(file_info$mtime),
    stringsAsFactors = FALSE
  )
}

#' Delete Session
#'
#' Delete a saved session
#'
#' @param filepath Character string. Path to session file
#' @return Logical. TRUE if deleted successfully
#' @export
delete_session <- function(filepath) {

  filepath <- path.expand(filepath)

  if (!file.exists(filepath)) {
    warning(paste("Session file not found:", filepath))
    return(FALSE)
  }

  tryCatch({
    file.remove(filepath)
    message(paste("Deleted session:", filepath))
    return(TRUE)
  }, error = function(e) {
    warning(paste("Error deleting session:", e$message))
    return(FALSE)
  })
}

#' Save User Preferences
#'
#' Save user preferences separately from session
#'
#' @param preferences List. User preferences
#' @param filepath Character string. Filepath (default: ~/.alaquer/preferences.rds)
#' @return Logical. TRUE if saved successfully
#' @export
save_preferences <- function(preferences,
                             filepath = "~/.alaquer/preferences.rds") {

  filepath <- path.expand(filepath)
  dir <- dirname(filepath)

  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  tryCatch({
    saveRDS(preferences, filepath)
    return(TRUE)
  }, error = function(e) {
    warning(paste("Error saving preferences:", e$message))
    return(FALSE)
  })
}

#' Load User Preferences
#'
#' Load saved user preferences
#'
#' @param filepath Character string. Filepath (default: ~/.alaquer/preferences.rds)
#' @return List with preferences, or default preferences if not found
#' @export
load_preferences <- function(filepath = "~/.alaquer/preferences.rds") {

  filepath <- path.expand(filepath)

  if (!file.exists(filepath)) {
    return(get_default_preferences())
  }

  tryCatch({
    readRDS(filepath)
  }, error = function(e) {
    warning(paste("Error loading preferences:", e$message))
    return(get_default_preferences())
  })
}

#' Get Default Preferences
#'
#' Return default user preferences
#'
#' @return List with default preferences
#' @export
get_default_preferences <- function() {
  list(
    theme = "light",
    ollama_host = "http://localhost:11434",
    default_model = NULL,
    temperature = 0.7,
    top_p = 0.9,
    max_tokens = 2000,
    auto_save = TRUE,
    auto_save_interval = 300,  # 5 minutes
    use_streaming = TRUE,
    show_token_count = TRUE,
    enable_keyboard_shortcuts = TRUE,
    format_code = TRUE,
    highlight_terms = TRUE,
    structure_text = TRUE,
    response_length = "normal",
    chunk_size = 500,
    chunk_overlap = 100,
    kb_max_results = 3
  )
}

#' Merge Preferences
#'
#' Merge user preferences with defaults
#'
#' @param user_prefs List. User preferences
#' @param defaults List. Default preferences
#' @return List with merged preferences
#' @export
merge_preferences <- function(user_prefs, defaults = get_default_preferences()) {
  # Start with defaults
  merged <- defaults

  # Override with user preferences
  for (name in names(user_prefs)) {
    merged[[name]] <- user_prefs[[name]]
  }

  return(merged)
}

#' Export Session
#'
#' Export session to a portable format
#'
#' @param session_data List. Session data
#' @param filepath Character string. Export filepath
#' @param format Character string. Format: "json" or "rds" (default: "json")
#' @return Character string with filepath, or NULL if error
#' @export
export_session <- function(session_data,
                          filepath,
                          format = "json") {

  tryCatch({
    if (format == "json") {
      json_data <- jsonlite::toJSON(
        session_data,
        pretty = TRUE,
        auto_unbox = TRUE
      )
      writeLines(as.character(json_data), filepath)
    } else {
      saveRDS(session_data, filepath)
    }

    return(filepath)

  }, error = function(e) {
    warning(paste("Error exporting session:", e$message))
    return(NULL)
  })
}

#' Import Session
#'
#' Import session from exported file
#'
#' @param filepath Character string. Import filepath
#' @return List with session data, or NULL if error
#' @export
import_session <- function(filepath) {

  if (!file.exists(filepath)) {
    warning(paste("File not found:", filepath))
    return(NULL)
  }

  tryCatch({
    ext <- tools::file_ext(filepath)

    if (ext == "json") {
      session_data <- jsonlite::fromJSON(filepath, simplifyVector = FALSE)
    } else if (ext == "rds") {
      session_data <- readRDS(filepath)
    } else {
      warning(paste("Unsupported format:", ext))
      return(NULL)
    }

    return(session_data)

  }, error = function(e) {
    warning(paste("Error importing session:", e$message))
    return(NULL)
  })
}

#' Get Session Storage Info
#'
#' Get information about session storage usage
#'
#' @param directory Character string. Storage directory
#' @return List with storage statistics
#' @export
get_session_storage_info <- function(directory = "~/.alaquer") {

  dir <- path.expand(directory)

  if (!dir.exists(dir)) {
    return(list(
      total_size = 0,
      session_count = 0,
      conversation_count = 0,
      preferences_exists = FALSE
    ))
  }

  # Get sessions
  sessions_dir <- file.path(dir, "sessions")
  session_count <- 0
  sessions_size <- 0

  if (dir.exists(sessions_dir)) {
    sessions <- list.files(sessions_dir, pattern = "\\.rds$", full.names = TRUE)
    session_count <- length(sessions)
    if (session_count > 0) {
      sessions_size <- sum(file.info(sessions)$size)
    }
  }

  # Get conversations
  convs_dir <- file.path(dir, "conversations")
  conv_count <- 0
  convs_size <- 0

  if (dir.exists(convs_dir)) {
    convs <- list.files(convs_dir, pattern = "\\.(rds|json)$", full.names = TRUE)
    conv_count <- length(convs)
    if (conv_count > 0) {
      convs_size <- sum(file.info(convs)$size)
    }
  }

  # Check preferences
  prefs_file <- file.path(dir, "preferences.rds")
  prefs_exists <- file.exists(prefs_file)
  prefs_size <- if (prefs_exists) file.info(prefs_file)$size else 0

  total_size <- sessions_size + convs_size + prefs_size

  list(
    total_size = format_file_size(total_size),
    total_size_bytes = total_size,
    session_count = session_count,
    sessions_size = format_file_size(sessions_size),
    conversation_count = conv_count,
    conversations_size = format_file_size(convs_size),
    preferences_exists = prefs_exists,
    preferences_size = format_file_size(prefs_size)
  )
}

#' Clean Old Sessions
#'
#' Delete sessions older than specified days
#'
#' @param days Integer. Delete sessions older than this many days
#' @param directory Character string. Storage directory
#' @return Integer. Number of sessions deleted
#' @export
clean_old_sessions <- function(days = 30,
                               directory = "~/.alaquer/sessions") {

  dir <- path.expand(directory)

  if (!dir.exists(dir)) {
    return(0)
  }

  files <- list.files(dir, pattern = "\\.rds$", full.names = TRUE)

  if (length(files) == 0) {
    return(0)
  }

  # Get file info
  file_info <- file.info(files)

  # Calculate age in days
  now <- Sys.time()
  ages <- difftime(now, file_info$mtime, units = "days")

  # Find old files
  old_files <- files[ages > days]

  if (length(old_files) == 0) {
    return(0)
  }

  # Delete old files
  deleted_count <- 0

  for (file in old_files) {
    if (file.remove(file)) {
      deleted_count <- deleted_count + 1
    }
  }

  message(paste("Deleted", deleted_count, "old sessions"))
  return(deleted_count)
}

#' Backup Session Data
#'
#' Create backup of all session data
#'
#' @param backup_path Character string. Backup filepath
#' @param directory Character string. Source directory
#' @return Character string with backup filepath, or NULL if error
#' @export
backup_session_data <- function(backup_path,
                                directory = "~/.alaquer") {

  dir <- path.expand(directory)

  if (!dir.exists(dir)) {
    warning("No session data to backup")
    return(NULL)
  }

  tryCatch({
    # Create archive of entire directory
    tar(backup_path, dir, compression = "gzip")

    message(paste("Backup created:", backup_path))
    return(backup_path)

  }, error = function(e) {
    warning(paste("Error creating backup:", e$message))
    return(NULL)
  })
}

#' Restore Session Data
#'
#' Restore session data from backup
#'
#' @param backup_path Character string. Backup filepath
#' @param directory Character string. Destination directory
#' @return Logical. TRUE if restored successfully
#' @export
restore_session_data <- function(backup_path,
                                 directory = "~/.alaquer") {

  if (!file.exists(backup_path)) {
    warning(paste("Backup file not found:", backup_path))
    return(FALSE)
  }

  dir <- path.expand(directory)

  tryCatch({
    # Extract archive
    untar(backup_path, exdir = dirname(dir))

    message(paste("Session data restored from:", backup_path))
    return(TRUE)

  }, error = function(e) {
    warning(paste("Error restoring backup:", e$message))
    return(FALSE)
  })
}

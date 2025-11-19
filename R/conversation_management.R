#' Conversation Management System
#'
#' Save, load, and manage conversation history
#'
#' @name conversation_management
NULL

#' Save Conversation to File
#'
#' Save a conversation history to a file
#'
#' @param conversation List. Conversation history
#' @param filename Character string. Filename to save to
#' @param directory Character string. Directory to save in (default: "~/.alaquer/conversations")
#' @param format Character string. Format: "rds", "json", "md" (default: "rds")
#' @return Character string with path to saved file, or NULL if error
#' @export
save_conversation <- function(conversation,
                              filename = NULL,
                              directory = "~/.alaquer/conversations",
                              format = "rds") {

  # Create directory if it doesn't exist
  dir <- path.expand(directory)
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  # Generate filename if not provided
  if (is.null(filename)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    filename <- paste0("conversation_", timestamp)
  }

  # Add extension based on format
  ext <- switch(format,
    "rds" = ".rds",
    "json" = ".json",
    "md" = ".md",
    ".rds"
  )

  if (!grepl(paste0(ext, "$"), filename)) {
    filename <- paste0(filename, ext)
  }

  filepath <- file.path(dir, filename)

  tryCatch({
    switch(format,
      "rds" = saveRDS(conversation, filepath),
      "json" = {
        json_data <- jsonlite::toJSON(conversation, pretty = TRUE, auto_unbox = TRUE)
        writeLines(json_data, filepath)
      },
      "md" = {
        md_content <- convert_conversation_to_markdown(conversation)
        writeLines(md_content, filepath)
      }
    )

    message(paste("Conversation saved to:", filepath))
    return(filepath)

  }, error = function(e) {
    warning(paste("Error saving conversation:", e$message))
    return(NULL)
  })
}

#' Load Conversation from File
#'
#' Load a saved conversation
#'
#' @param filepath Character string. Path to conversation file
#' @return List with conversation data, or NULL if error
#' @export
load_conversation <- function(filepath) {

  filepath <- path.expand(filepath)

  if (!file.exists(filepath)) {
    warning(paste("File not found:", filepath))
    return(NULL)
  }

  tryCatch({
    ext <- tools::file_ext(filepath)

    conversation <- switch(ext,
      "rds" = readRDS(filepath),
      "json" = jsonlite::fromJSON(filepath, simplifyVector = FALSE),
      {
        warning(paste("Unsupported format:", ext))
        return(NULL)
      }
    )

    return(conversation)

  }, error = function(e) {
    warning(paste("Error loading conversation:", e$message))
    return(NULL)
  })
}

#' List Saved Conversations
#'
#' Get list of all saved conversations
#'
#' @param directory Character string. Directory to search (default: "~/.alaquer/conversations")
#' @param format Character string. Filter by format: "rds", "json", "all" (default: "all")
#' @return Data frame with conversation info
#' @export
list_conversations <- function(directory = "~/.alaquer/conversations",
                               format = "all") {

  dir <- path.expand(directory)

  if (!dir.exists(dir)) {
    return(data.frame(
      filename = character(),
      path = character(),
      size = numeric(),
      modified = character(),
      format = character()
    ))
  }

  # Get files based on format
  pattern <- switch(format,
    "rds" = "\\.rds$",
    "json" = "\\.json$",
    "all" = "\\.(rds|json)$",
    "\\.(rds|json)$"
  )

  files <- list.files(dir, pattern = pattern, full.names = TRUE)

  if (length(files) == 0) {
    return(data.frame(
      filename = character(),
      path = character(),
      size = numeric(),
      modified = character(),
      format = character()
    ))
  }

  # Get file info
  file_info <- file.info(files)

  data.frame(
    filename = basename(files),
    path = files,
    size = file_info$size,
    modified = as.character(file_info$mtime),
    format = tools::file_ext(files),
    stringsAsFactors = FALSE
  )
}

#' Delete Saved Conversation
#'
#' Delete a saved conversation file
#'
#' @param filepath Character string. Path to conversation file
#' @return Logical. TRUE if deleted successfully
#' @export
delete_conversation <- function(filepath) {

  filepath <- path.expand(filepath)

  if (!file.exists(filepath)) {
    warning(paste("File not found:", filepath))
    return(FALSE)
  }

  tryCatch({
    file.remove(filepath)
    message(paste("Deleted conversation:", filepath))
    return(TRUE)
  }, error = function(e) {
    warning(paste("Error deleting conversation:", e$message))
    return(FALSE)
  })
}

#' Search Conversations
#'
#' Search through saved conversations for specific text
#'
#' @param query Character string. Search query
#' @param directory Character string. Directory to search (default: "~/.alaquer/conversations")
#' @param case_sensitive Logical. Case-sensitive search (default: FALSE)
#' @return Data frame with matching conversations and snippets
#' @export
search_conversations <- function(query,
                                 directory = "~/.alaquer/conversations",
                                 case_sensitive = FALSE) {

  conversations <- list_conversations(directory, format = "all")

  if (nrow(conversations) == 0) {
    return(data.frame(
      filename = character(),
      match_count = numeric(),
      snippet = character()
    ))
  }

  results <- list()

  for (i in 1:nrow(conversations)) {
    filepath <- conversations$path[i]
    conv <- load_conversation(filepath)

    if (is.null(conv)) next

    # Search through messages
    matches <- 0
    snippets <- character()

    for (msg in conv) {
      content <- if (is.list(msg)) msg$content else as.character(msg)

      if (case_sensitive) {
        if (grepl(query, content)) {
          matches <- matches + 1
          snippet <- substr(content, 1, 100)
          snippets <- c(snippets, snippet)
        }
      } else {
        if (grepl(query, content, ignore.case = TRUE)) {
          matches <- matches + 1
          snippet <- substr(content, 1, 100)
          snippets <- c(snippets, snippet)
        }
      }
    }

    if (matches > 0) {
      results[[length(results) + 1]] <- data.frame(
        filename = conversations$filename[i],
        path = filepath,
        match_count = matches,
        snippet = paste(snippets[1:min(3, length(snippets))], collapse = " ... "),
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(results) == 0) {
    return(data.frame(
      filename = character(),
      match_count = numeric(),
      snippet = character()
    ))
  }

  do.call(rbind, results)
}

#' Convert Conversation to Markdown
#'
#' Internal function to convert conversation to markdown format
#'
#' @param conversation List. Conversation history
#' @return Character vector with markdown lines
#' @keywords internal
convert_conversation_to_markdown <- function(conversation) {

  md_lines <- c(
    "# ALAQUER Conversation",
    paste("**Saved:**", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    paste("**Messages:**", length(conversation)),
    "",
    "---",
    ""
  )

  for (i in seq_along(conversation)) {
    msg <- conversation[[i]]

    type <- if (is.list(msg)) msg$type else "unknown"
    content <- if (is.list(msg)) msg$content else as.character(msg)
    timestamp <- if (is.list(msg) && !is.null(msg$timestamp)) {
      format(msg$timestamp, "%H:%M:%S")
    } else {
      ""
    }

    header <- if (type == "user") {
      paste0("## 👤 User", if (timestamp != "") paste0(" (", timestamp, ")") else "")
    } else if (type == "ai") {
      paste0("## 🤖 AI Assistant", if (timestamp != "") paste0(" (", timestamp, ")") else "")
    } else {
      paste0("## Message ", i)
    }

    md_lines <- c(md_lines, header, "", content, "", "---", "")
  }

  md_lines
}

#' Get Conversation Statistics
#'
#' Get statistics about a conversation
#'
#' @param conversation List. Conversation history
#' @return List with statistics
#' @export
get_conversation_stats <- function(conversation) {

  if (is.null(conversation) || length(conversation) == 0) {
    return(list(
      message_count = 0,
      user_messages = 0,
      ai_messages = 0,
      total_words = 0,
      avg_message_length = 0
    ))
  }

  user_msgs <- 0
  ai_msgs <- 0
  total_words <- 0
  word_counts <- numeric()

  for (msg in conversation) {
    type <- if (is.list(msg)) msg$type else NULL
    content <- if (is.list(msg)) msg$content else as.character(msg)

    if (!is.null(type)) {
      if (type == "user") user_msgs <- user_msgs + 1
      if (type == "ai") ai_msgs <- ai_msgs + 1
    }

    words <- length(unlist(strsplit(content, "\\s+")))
    total_words <- total_words + words
    word_counts <- c(word_counts, words)
  }

  list(
    message_count = length(conversation),
    user_messages = user_msgs,
    ai_messages = ai_msgs,
    total_words = total_words,
    avg_message_length = if (length(word_counts) > 0) mean(word_counts) else 0,
    min_message_length = if (length(word_counts) > 0) min(word_counts) else 0,
    max_message_length = if (length(word_counts) > 0) max(word_counts) else 0
  )
}

#' Auto-save Conversation
#'
#' Automatically save conversation at intervals
#'
#' @param conversation List. Conversation to save
#' @param interval Numeric. Save interval in seconds (default: 300 = 5 minutes)
#' @param directory Character string. Save directory
#' @return Character string with autosave filepath
#' @export
autosave_conversation <- function(conversation,
                                  interval = 300,
                                  directory = "~/.alaquer/conversations") {

  dir <- path.expand(directory)
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  autosave_file <- file.path(dir, "autosave.rds")

  tryCatch({
    saveRDS(list(
      conversation = conversation,
      timestamp = Sys.time()
    ), autosave_file)

    return(autosave_file)

  }, error = function(e) {
    warning(paste("Autosave failed:", e$message))
    return(NULL)
  })
}

#' Load Autosaved Conversation
#'
#' Load the most recent autosaved conversation
#'
#' @param directory Character string. Save directory
#' @return List with conversation, or NULL if none found
#' @export
load_autosave <- function(directory = "~/.alaquer/conversations") {

  dir <- path.expand(directory)
  autosave_file <- file.path(dir, "autosave.rds")

  if (!file.exists(autosave_file)) {
    return(NULL)
  }

  tryCatch({
    data <- readRDS(autosave_file)

    # Check if autosave is recent (within 24 hours)
    age <- difftime(Sys.time(), data$timestamp, units = "hours")

    if (age > 24) {
      message("Autosave is older than 24 hours, ignoring")
      return(NULL)
    }

    message(paste("Found autosave from", format(data$timestamp, "%Y-%m-%d %H:%M:%S")))
    return(data$conversation)

  }, error = function(e) {
    warning(paste("Error loading autosave:", e$message))
    return(NULL)
  })
}

#' ALAQUER Enhancements
#'
#' Advanced features including multi-model comparison, themes,
#' quality tracking, and more
#'
#' @name enhancements
NULL

# ============================================================================
# MULTI-MODEL COMPARISON
# ============================================================================

#' Compare Multiple Models
#'
#' Get responses from multiple models for the same prompt and compare
#'
#' @param prompt Character string. The prompt to send
#' @param models Character vector. Model names to compare
#' @param host Character string. Ollama host
#' @param temperature Numeric. Temperature parameter
#' @param max_tokens Integer. Max tokens
#' @return Data frame with model comparisons
#' @export
compare_models <- function(prompt,
                          models,
                          host = "http://localhost:11434",
                          temperature = 0.7,
                          max_tokens = 500) {

  if (length(models) == 0) {
    stop("At least one model required")
  }

  results <- list()

  for (model in models) {
    message(paste("Querying", model, "..."))

    start_time <- Sys.time()

    response <- ollama_query(
      prompt = prompt,
      model = model,
      host = host,
      temperature = temperature,
      max_tokens = max_tokens
    )

    end_time <- Sys.time()
    duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

    if (!is.null(response)) {
      results[[length(results) + 1]] <- data.frame(
        model = model,
        response = response$text,
        duration = duration,
        eval_count = if (!is.null(response$eval_count)) response$eval_count else NA,
        tokens_per_sec = if (!is.null(response$eval_count) && duration > 0) {
          response$eval_count / duration
        } else {
          NA
        },
        response_length = nchar(response$text),
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(results) == 0) {
    return(data.frame())
  }

  do.call(rbind, results)
}

# ============================================================================
# THEME SYSTEM
# ============================================================================

#' Get Available Themes
#'
#' Return list of available UI themes
#'
#' @return List of theme configurations
#' @export
get_themes <- function() {
  list(
    light = list(
      name = "Light Mode",
      bg_color = "#ffffff",
      text_color = "#374151",
      primary_color = "#10a37f",
      secondary_color = "#7c3aed",
      chat_bg = "#f7f7f8",
      user_msg_bg = "#f0f0f0",
      ai_msg_bg = "#ffffff",
      user_msg_border = "#10a37f",
      ai_msg_border = "#7c3aed"
    ),
    dark = list(
      name = "Dark Mode",
      bg_color = "#1a1a1a",
      text_color = "#e5e7eb",
      primary_color = "#10a37f",
      secondary_color = "#8b5cf6",
      chat_bg = "#2d2d2d",
      user_msg_bg = "#3a3a3a",
      ai_msg_bg = "#2d2d2d",
      user_msg_border = "#10a37f",
      ai_msg_border = "#8b5cf6"
    ),
    ocean = list(
      name = "Ocean Blue",
      bg_color = "#f0f9ff",
      text_color = "#1e3a8a",
      primary_color = "#0284c7",
      secondary_color = "#7c3aed",
      chat_bg = "#e0f2fe",
      user_msg_bg = "#bae6fd",
      ai_msg_bg = "#e0f2fe",
      user_msg_border = "#0284c7",
      ai_msg_border = "#7c3aed"
    ),
    forest = list(
      name = "Forest Green",
      bg_color = "#f0fdf4",
      text_color = "#14532d",
      primary_color = "#059669",
      secondary_color = "#7c3aed",
      chat_bg = "#dcfce7",
      user_msg_bg = "#bbf7d0",
      ai_msg_bg = "#dcfce7",
      user_msg_border = "#059669",
      ai_msg_border = "#7c3aed"
    ),
    sunset = list(
      name = "Sunset",
      bg_color = "#fff7ed",
      text_color = "#7c2d12",
      primary_color = "#ea580c",
      secondary_color = "#7c3aed",
      chat_bg = "#ffedd5",
      user_msg_bg = "#fed7aa",
      ai_msg_bg = "#ffedd5",
      user_msg_border = "#ea580c",
      ai_msg_border = "#7c3aed"
    )
  )
}

#' Generate Theme CSS
#'
#' Generate CSS for a specific theme
#'
#' @param theme_name Character string. Theme name
#' @return Character string with CSS
#' @export
generate_theme_css <- function(theme_name = "light") {
  themes <- get_themes()

  if (!theme_name %in% names(themes)) {
    theme_name <- "light"
  }

  theme <- themes[[theme_name]]

  css <- sprintf("
    body {
      background-color: %s !important;
      color: %s !important;
    }

    #chat_display {
      background-color: %s !important;
    }

    .user-message {
      background-color: %s !important;
      border-left-color: %s !important;
    }

    .ai-message {
      background-color: %s !important;
      border-left-color: %s !important;
    }

    .btn-primary {
      background-color: %s !important;
      border-color: %s !important;
    }

    .box-header {
      background-color: %s !important;
    }
  ",
    theme$bg_color,
    theme$text_color,
    theme$chat_bg,
    theme$user_msg_bg,
    theme$user_msg_border,
    theme$ai_msg_bg,
    theme$ai_msg_border,
    theme$primary_color,
    theme$primary_color,
    theme$chat_bg
  )

  return(css)
}

# ============================================================================
# RESPONSE QUALITY TRACKING
# ============================================================================

#' Rate Response Quality
#'
#' Rate an AI response
#'
#' @param response_id Character string. Unique response ID
#' @param rating Integer. Rating 1-5
#' @param feedback Character string. Optional feedback (default: NULL)
#' @param directory Character string. Storage directory
#' @return Logical. TRUE if saved successfully
#' @export
rate_response <- function(response_id,
                         rating,
                         feedback = NULL,
                         directory = "~/.alaquer/ratings") {

  if (rating < 1 || rating > 5) {
    stop("Rating must be between 1 and 5")
  }

  dir <- path.expand(directory)
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  rating_data <- list(
    response_id = response_id,
    rating = rating,
    feedback = feedback,
    timestamp = Sys.time()
  )

  filepath <- file.path(dir, paste0(response_id, ".rds"))

  tryCatch({
    saveRDS(rating_data, filepath)
    return(TRUE)
  }, error = function(e) {
    warning(paste("Error saving rating:", e$message))
    return(FALSE)
  })
}

#' Get Response Ratings
#'
#' Get all ratings for analysis
#'
#' @param directory Character string. Storage directory
#' @return Data frame with ratings
#' @export
get_response_ratings <- function(directory = "~/.alaquer/ratings") {
  dir <- path.expand(directory)

  if (!dir.exists(dir)) {
    return(data.frame(
      response_id = character(),
      rating = numeric(),
      feedback = character(),
      timestamp = character()
    ))
  }

  files <- list.files(dir, pattern = "\\.rds$", full.names = TRUE)

  if (length(files) == 0) {
    return(data.frame(
      response_id = character(),
      rating = numeric(),
      feedback = character(),
      timestamp = character()
    ))
  }

  ratings <- lapply(files, function(f) {
    data <- readRDS(f)
    data.frame(
      response_id = data$response_id,
      rating = data$rating,
      feedback = if (is.null(data$feedback)) "" else data$feedback,
      timestamp = as.character(data$timestamp),
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, ratings)
}

#' Get Rating Statistics
#'
#' Calculate statistics from ratings
#'
#' @param ratings Data frame. Ratings data
#' @return List with statistics
#' @export
get_rating_statistics <- function(ratings) {
  if (nrow(ratings) == 0) {
    return(list(
      total_ratings = 0,
      average_rating = 0,
      rating_distribution = numeric(5)
    ))
  }

  list(
    total_ratings = nrow(ratings),
    average_rating = mean(ratings$rating),
    median_rating = median(ratings$rating),
    rating_distribution = table(ratings$rating),
    five_star_percent = sum(ratings$rating == 5) / nrow(ratings) * 100,
    one_star_percent = sum(ratings$rating == 1) / nrow(ratings) * 100
  )
}

# ============================================================================
# KEYBOARD SHORTCUTS
# ============================================================================

#' Get Keyboard Shortcuts
#'
#' Return list of keyboard shortcuts for the UI
#'
#' @return List of shortcuts
#' @export
get_keyboard_shortcuts <- function() {
  list(
    send_message = list(
      key = "Enter",
      description = "Send message"
    ),
    new_line = list(
      key = "Shift+Enter",
      description = "New line in input"
    ),
    clear_input = list(
      key = "Ctrl+L",
      description = "Clear input box"
    ),
    focus_input = list(
      key = "Ctrl+/",
      description = "Focus input box"
    ),
    copy_last = list(
      key = "Ctrl+Shift+C",
      description = "Copy last response"
    ),
    new_conversation = list(
      key = "Ctrl+N",
      description = "New conversation"
    ),
    save_conversation = list(
      key = "Ctrl+S",
      description = "Save conversation"
    ),
    search = list(
      key = "Ctrl+F",
      description = "Search conversations"
    ),
    toggle_sidebar = list(
      key = "Ctrl+B",
      description = "Toggle sidebar"
    ),
    help = list(
      key = "Ctrl+H",
      description = "Show help"
    )
  )
}

# ============================================================================
# MODEL MANAGEMENT
# ============================================================================

#' List Available Models with Details
#'
#' Get detailed information about available models
#'
#' @param host Character string. Ollama host
#' @return Data frame with model details
#' @export
list_model_details <- function(host = "http://localhost:11434") {
  tryCatch({
    response <- httr::GET(paste0(host, "/api/tags"))

    if (httr::status_code(response) != 200) {
      return(data.frame())
    }

    content <- httr::content(response, as = "parsed")

    if (is.null(content$models) || length(content$models) == 0) {
      return(data.frame())
    }

    models <- lapply(content$models, function(m) {
      data.frame(
        name = m$name,
        size = if (!is.null(m$size)) format_file_size(m$size) else "Unknown",
        modified = if (!is.null(m$modified_at)) m$modified_at else "Unknown",
        family = if (!is.null(m$details$family)) m$details$family else "Unknown",
        parameter_size = if (!is.null(m$details$parameter_size)) m$details$parameter_size else "Unknown",
        stringsAsFactors = FALSE
      )
    })

    do.call(rbind, models)

  }, error = function(e) {
    warning(paste("Error listing models:", e$message))
    return(data.frame())
  })
}

#' Delete Model
#'
#' Delete an Ollama model
#'
#' @param model_name Character string. Model name to delete
#' @param host Character string. Ollama host
#' @return Logical. TRUE if deleted successfully
#' @export
delete_model <- function(model_name, host = "http://localhost:11434") {
  tryCatch({
    body <- list(name = model_name)

    response <- httr::request(
      paste0(host, "/api/delete"),
      method = "DELETE",
      body = jsonlite::toJSON(body, auto_unbox = TRUE),
      httr::add_headers("Content-Type" = "application/json")
    )

    return(httr::status_code(response) == 200)

  }, error = function(e) {
    warning(paste("Error deleting model:", e$message))
    return(FALSE)
  })
}

#' Get Model Info
#'
#' Get detailed information about a specific model
#'
#' @param model_name Character string. Model name
#' @param host Character string. Ollama host
#' @return List with model information
#' @export
get_model_info <- function(model_name, host = "http://localhost:11434") {
  tryCatch({
    body <- list(name = model_name)

    response <- httr::POST(
      paste0(host, "/api/show"),
      body = jsonlite::toJSON(body, auto_unbox = TRUE),
      httr::add_headers("Content-Type" = "application/json"),
      encode = "raw"
    )

    if (httr::status_code(response) != 200) {
      return(NULL)
    }

    httr::content(response, as = "parsed")

  }, error = function(e) {
    warning(paste("Error getting model info:", e$message))
    return(NULL)
  })
}

# ============================================================================
# EXPORT FORMATS
# ============================================================================

#' Export Conversation to HTML
#'
#' Export conversation as HTML file
#'
#' @param conversation List. Conversation history
#' @param filepath Character string. Output filepath
#' @param include_css Logical. Include embedded CSS (default: TRUE)
#' @return Character string with filepath, or NULL if error
#' @export
export_to_html <- function(conversation, filepath, include_css = TRUE) {
  tryCatch({
    html <- c(
      "<!DOCTYPE html>",
      "<html>",
      "<head>",
      "<meta charset='UTF-8'>",
      "<title>ALAQUER Conversation</title>"
    )

    if (include_css) {
      html <- c(html,
        "<style>",
        "body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background: #f5f5f5; }",
        ".message { margin: 20px 0; padding: 15px; border-radius: 8px; }",
        ".user-message { background: #e3f2fd; border-left: 4px solid #2196f3; }",
        ".ai-message { background: #f3e5f5; border-left: 4px solid #9c27b0; }",
        ".timestamp { font-size: 0.8em; color: #666; }",
        "pre { background: #f5f5f5; padding: 10px; border-radius: 4px; overflow-x: auto; }",
        "</style>"
      )
    }

    html <- c(html, "</head>", "<body>",
      paste0("<h1>ALAQUER Conversation - ", format(Sys.time(), "%Y-%m-%d"), "</h1>"))

    for (msg in conversation) {
      type <- if (is.list(msg)) msg$type else "unknown"
      content <- if (is.list(msg)) msg$content else as.character(msg)
      timestamp <- if (is.list(msg) && !is.null(msg$timestamp)) {
        format(msg$timestamp, "%H:%M:%S")
      } else {
        ""
      }

      class_name <- if (type == "user") "user-message" else "ai-message"
      label <- if (type == "user") "👤 You" else "🤖 AI Assistant"

      html <- c(html,
        paste0("<div class='message ", class_name, "'>"),
        paste0("<strong>", label, "</strong>"),
        if (timestamp != "") paste0("<span class='timestamp'> - ", timestamp, "</span>") else "",
        paste0("<div>", gsub("\n", "<br>", content), "</div>"),
        "</div>"
      )
    }

    html <- c(html, "</body>", "</html>")

    writeLines(html, filepath)
    return(filepath)

  }, error = function(e) {
    warning(paste("Error exporting to HTML:", e$message))
    return(NULL)
  })
}

#' Export Conversation to JSON
#'
#' Export conversation as JSON file
#'
#' @param conversation List. Conversation history
#' @param filepath Character string. Output filepath
#' @param pretty Logical. Pretty print JSON (default: TRUE)
#' @return Character string with filepath, or NULL if error
#' @export
export_to_json <- function(conversation, filepath, pretty = TRUE) {
  tryCatch({
    json_data <- jsonlite::toJSON(
      list(
        exported = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        message_count = length(conversation),
        messages = conversation
      ),
      pretty = pretty,
      auto_unbox = TRUE
    )

    writeLines(as.character(json_data), filepath)
    return(filepath)

  }, error = function(e) {
    warning(paste("Error exporting to JSON:", e$message))
    return(NULL)
  })
}

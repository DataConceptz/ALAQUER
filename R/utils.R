#' Check System Requirements
#'
#' Verify that system meets ALAQUER requirements
#'
#' @return List with requirement check results
#' @export
#' @examples
#' \dontrun{
#' reqs <- check_system_requirements()
#' print(reqs)
#' }
check_system_requirements <- function() {
  requirements <- list(
    r_version = list(
      required = "4.0.0",
      installed = paste0(R.version$major, ".", R.version$minor),
      met = getRversion() >= "4.0.0"
    ),
    packages = list(),
    ollama = list(
      available = check_ollama_connection()
    )
  )

  # Check required packages
  required_packages <- c(
    "shiny", "shinydashboard", "shinyWidgets", "DT",
    "httr", "jsonlite", "clipr", "readr", "readxl",
    "pdftools", "tm", "stringr", "dplyr"
  )

  for (pkg in required_packages) {
    requirements$packages[[pkg]] <- list(
      installed = requireNamespace(pkg, quietly = TRUE),
      version = if (requireNamespace(pkg, quietly = TRUE)) {
        as.character(packageVersion(pkg))
      } else {
        NA
      }
    )
  }

  # Overall status
  all_packages_ok <- all(sapply(requirements$packages, function(p) p$installed))
  requirements$status <- if (requirements$r_version$met && all_packages_ok) {
    "ready"
  } else if (requirements$r_version$met) {
    "missing_packages"
  } else {
    "r_version_too_old"
  }

  return(requirements)
}

#' Format File Size
#'
#' Format bytes into human-readable file size
#'
#' @param bytes Numeric. File size in bytes
#' @return Character string with formatted size
format_file_size <- function(bytes) {
  if (bytes < 1024) {
    return(paste(bytes, "B"))
  } else if (bytes < 1024^2) {
    return(paste(round(bytes / 1024, 2), "KB"))
  } else if (bytes < 1024^3) {
    return(paste(round(bytes / 1024^2, 2), "MB"))
  } else {
    return(paste(round(bytes / 1024^3, 2), "GB"))
  }
}

#' Format Duration
#'
#' Format duration in milliseconds to human-readable format
#'
#' @param ms Numeric. Duration in milliseconds
#' @return Character string with formatted duration
format_duration <- function(ms) {
  if (ms < 1000) {
    return(paste(round(ms), "ms"))
  } else if (ms < 60000) {
    return(paste(round(ms / 1000, 1), "s"))
  } else if (ms < 3600000) {
    minutes <- floor(ms / 60000)
    seconds <- round((ms %% 60000) / 1000)
    return(paste(minutes, "m", seconds, "s"))
  } else {
    hours <- floor(ms / 3600000)
    minutes <- round((ms %% 3600000) / 60000)
    return(paste(hours, "h", minutes, "m"))
  }
}

#' Truncate Text
#'
#' Truncate text to specified length with ellipsis
#'
#' @param text Character string. Text to truncate
#' @param max_length Integer. Maximum length (default: 100)
#' @param ellipsis Character string. Ellipsis to append (default: "...")
#' @return Character string with truncated text
truncate_text <- function(text, max_length = 100, ellipsis = "...") {
  if (nchar(text) <= max_length) {
    return(text)
  }

  truncated <- substr(text, 1, max_length - nchar(ellipsis))
  return(paste0(truncated, ellipsis))
}

#' Safe File Read
#'
#' Safely read file with error handling
#'
#' @param file_path Character string. Path to file
#' @param encoding Character string. File encoding (default: "UTF-8")
#' @return Character string with file contents, or NULL if error
safe_file_read <- function(file_path, encoding = "UTF-8") {
  tryCatch({
    if (!file.exists(file_path)) {
      warning(paste("File not found:", file_path))
      return(NULL)
    }

    content <- readr::read_file(file_path)
    return(content)

  }, error = function(e) {
    warning(paste("Error reading file:", file_path, "-", e$message))
    return(NULL)
  })
}

#' Clean Text
#'
#' Clean and normalize text
#'
#' @param text Character string. Text to clean
#' @param remove_extra_whitespace Logical. Remove extra whitespace (default: TRUE)
#' @param remove_special_chars Logical. Remove special characters (default: FALSE)
#' @return Character string with cleaned text
clean_text <- function(text,
                      remove_extra_whitespace = TRUE,
                      remove_special_chars = FALSE) {

  # Remove extra whitespace
  if (remove_extra_whitespace) {
    text <- gsub("\\s+", " ", text)
    text <- trimws(text)
  }

  # Remove special characters if requested
  if (remove_special_chars) {
    text <- gsub("[^[:alnum:][:space:].,!?-]", "", text)
  }

  return(text)
}

#' Validate Email
#'
#' Simple email validation
#'
#' @param email Character string. Email to validate
#' @return Logical. TRUE if valid email format
validate_email <- function(email) {
  pattern <- "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
  return(grepl(pattern, email))
}

#' Validate URL
#'
#' Simple URL validation
#'
#' @param url Character string. URL to validate
#' @return Logical. TRUE if valid URL format
validate_url <- function(url) {
  pattern <- "^https?://[^\\s/$.?#].[^\\s]*$"
  return(grepl(pattern, url, ignore.case = TRUE))
}

#' Generate Random ID
#'
#' Generate random alphanumeric ID
#'
#' @param length Integer. Length of ID (default: 8)
#' @return Character string with random ID
generate_random_id <- function(length = 8) {
  chars <- c(letters, LETTERS, 0:9)
  return(paste(sample(chars, length, replace = TRUE), collapse = ""))
}

#' Safe Division
#'
#' Perform division with zero handling
#'
#' @param numerator Numeric. Numerator
#' @param denominator Numeric. Denominator
#' @param default Numeric. Default value if division by zero (default: 0)
#' @return Numeric result of division
safe_divide <- function(numerator, denominator, default = 0) {
  if (denominator == 0) {
    return(default)
  }
  return(numerator / denominator)
}

#' Retry Function
#'
#' Retry a function call with exponential backoff
#'
#' @param func Function. Function to retry
#' @param max_attempts Integer. Maximum retry attempts (default: 3)
#' @param initial_wait Numeric. Initial wait time in seconds (default: 1)
#' @param backoff_factor Numeric. Backoff multiplier (default: 2)
#' @return Result of successful function call, or NULL if all attempts fail
retry_function <- function(func,
                          max_attempts = 3,
                          initial_wait = 1,
                          backoff_factor = 2) {

  attempt <- 1
  wait_time <- initial_wait

  while (attempt <= max_attempts) {
    result <- tryCatch({
      func()
    }, error = function(e) {
      if (attempt < max_attempts) {
        message(paste("Attempt", attempt, "failed. Retrying in", wait_time, "seconds..."))
        Sys.sleep(wait_time)
        wait_time <<- wait_time * backoff_factor
      } else {
        warning(paste("All", max_attempts, "attempts failed:", e$message))
      }
      NULL
    })

    if (!is.null(result)) {
      return(result)
    }

    attempt <- attempt + 1
  }

  return(NULL)
}

#' Create Timestamp
#'
#' Create formatted timestamp string
#'
#' @param format Character string. Format string (default: "%Y-%m-%d %H:%M:%S")
#' @return Character string with formatted timestamp
create_timestamp <- function(format = "%Y-%m-%d %H:%M:%S") {
  return(format(Sys.time(), format))
}

#' Calculate Percentage
#'
#' Calculate percentage with proper formatting
#'
#' @param value Numeric. Value
#' @param total Numeric. Total
#' @param digits Integer. Decimal places (default: 1)
#' @return Character string with percentage
calculate_percentage <- function(value, total, digits = 1) {
  if (total == 0) {
    return("0%")
  }
  pct <- (value / total) * 100
  return(paste0(round(pct, digits), "%"))
}

#' Parse Version String
#'
#' Parse semantic version string into components
#'
#' @param version Character string. Version string (e.g., "1.2.3")
#' @return List with major, minor, patch components
parse_version <- function(version) {
  parts <- strsplit(version, "\\.")[[1]]

  return(list(
    major = as.integer(parts[1]),
    minor = if (length(parts) >= 2) as.integer(parts[2]) else 0,
    patch = if (length(parts) >= 3) as.integer(parts[3]) else 0
  ))
}

#' Compare Versions
#'
#' Compare two semantic version strings
#'
#' @param version1 Character string. First version
#' @param version2 Character string. Second version
#' @return Integer. -1 if version1 < version2, 0 if equal, 1 if version1 > version2
compare_versions <- function(version1, version2) {
  v1 <- parse_version(version1)
  v2 <- parse_version(version2)

  if (v1$major != v2$major) {
    return(ifelse(v1$major > v2$major, 1, -1))
  }

  if (v1$minor != v2$minor) {
    return(ifelse(v1$minor > v2$minor, 1, -1))
  }

  if (v1$patch != v2$patch) {
    return(ifelse(v1$patch > v2$patch, 1, -1))
  }

  return(0)
}

#' Create Progress Message
#'
#' Create formatted progress message
#'
#' @param current Integer. Current progress
#' @param total Integer. Total items
#' @param prefix Character string. Message prefix (default: "Processing")
#' @return Character string with progress message
create_progress_message <- function(current, total, prefix = "Processing") {
  percentage <- calculate_percentage(current, total)
  return(paste0(prefix, ": ", current, "/", total, " (", percentage, ")"))
}

#' Sanitize Filename
#'
#' Sanitize filename by removing/replacing invalid characters
#'
#' @param filename Character string. Filename to sanitize
#' @return Character string with sanitized filename
sanitize_filename <- function(filename) {
  # Remove or replace invalid characters
  filename <- gsub("[<>:\"/\\|?*]", "_", filename)

  # Remove leading/trailing dots and spaces
  filename <- gsub("^[\\.\\s]+|[\\.\\s]+$", "", filename)

  # Ensure it's not empty
  if (nchar(filename) == 0) {
    filename <- "unnamed"
  }

  return(filename)
}

#' Deep Copy List
#'
#' Create a deep copy of a list
#'
#' @param x List. List to copy
#' @return List. Deep copy
deep_copy_list <- function(x) {
  return(jsonlite::fromJSON(jsonlite::toJSON(x, auto_unbox = FALSE)))
}

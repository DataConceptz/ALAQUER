#' Detect Code Blocks
#'
#' Identify code blocks in text
#'
#' @param text Character string. Text to analyze
#' @return List with code block information
detect_code_blocks <- function(text) {
  # Look for markdown code blocks
  markdown_pattern <- "```[a-z]*\\n[\\s\\S]*?```"
  markdown_blocks <- gregexpr(markdown_pattern, text, perl = TRUE)

  # Look for indented code blocks
  lines <- strsplit(text, "\n")[[1]]
  indented_blocks <- which(grepl("^\\s{4,}", lines))

  code_blocks <- list(
    has_code = (markdown_blocks[[1]][1] != -1) || (length(indented_blocks) > 0),
    markdown_blocks = markdown_blocks,
    indented_lines = indented_blocks
  )

  return(code_blocks)
}

#' Format Code Blocks
#'
#' Enhance formatting of code blocks
#'
#' @param text Character string. Text containing code
#' @return Character string with formatted code
format_code_blocks <- function(text) {
  # Ensure code blocks have proper syntax highlighting hints
  text <- gsub("```\\n", "```plaintext\n", text, perl = TRUE)

  # Add line breaks before and after code blocks for better readability
  text <- gsub("([^\\n])```", "\\1\n```", text, perl = TRUE)
  text <- gsub("```([^\\n])", "```\n\\1", text, perl = TRUE)

  return(text)
}

#' Detect Technical Terms
#'
#' Identify technical terminology in text
#'
#' @param text Character string. Text to analyze
#' @return Character vector of detected technical terms
detect_technical_terms <- function(text) {
  # Common technical term patterns
  patterns <- c(
    "\\b[A-Z]{2,}\\b",  # Acronyms
    "\\b[a-z]+\\.[a-z]+\\b",  # Dotted notation (e.g., file.txt)
    "\\b[A-Z][a-z]+[A-Z][a-zA-Z]*\\b",  # CamelCase
    "\\b[a-z]+_[a-z_]+\\b",  # snake_case
    "\\b[a-z]+-[a-z-]+\\b"  # kebab-case
  )

  terms <- character()

  for (pattern in patterns) {
    matches <- regmatches(text, gregexpr(pattern, text, perl = TRUE))[[1]]
    terms <- c(terms, matches)
  }

  # Remove duplicates
  terms <- unique(terms)

  # Filter out common words
  common_words <- c("The", "This", "That", "With", "From", "Into", "About")
  terms <- terms[!terms %in% common_words]

  return(terms)
}

#' Highlight Technical Terms
#'
#' Add markdown formatting to technical terms
#'
#' @param text Character string. Text to process
#' @param terms Character vector. Terms to highlight
#' @return Character string with highlighted terms
highlight_technical_terms <- function(text, terms) {
  if (length(terms) == 0) {
    return(text)
  }

  for (term in terms) {
    # Only highlight if not already in code blocks or bold/italic
    pattern <- paste0("(?<![`*_])\\b", gsub("([.+*?^$(){}\\[\\]|\\\\])", "\\\\\\1", term), "\\b(?![`*_])")
    replacement <- paste0("`", term, "`")
    text <- gsub(pattern, replacement, text, perl = TRUE)
  }

  return(text)
}

#' Structure Text Content
#'
#' Improve text structure with better paragraphing and spacing
#'
#' @param text Character string. Text to structure
#' @return Character string with improved structure
structure_text <- function(text) {
  # Split into lines
  lines <- strsplit(text, "\n")[[1]]

  # Remove excessive blank lines
  lines <- gsub("\\n{3,}", "\n\n", paste(lines, collapse = "\n"))
  lines <- strsplit(lines, "\n")[[1]]

  # Ensure proper spacing after punctuation
  lines <- sapply(lines, function(line) {
    line <- gsub("([.!?])([A-Z])", "\\1 \\2", line)
    line <- gsub("([,;:])([A-Za-z])", "\\1 \\2", line)
    return(line)
  })

  # Combine back
  text <- paste(lines, collapse = "\n")

  return(text)
}

#' Add List Formatting
#'
#' Detect and format lists properly
#'
#' @param text Character string. Text to format
#' @return Character string with formatted lists
format_lists <- function(text) {
  lines <- strsplit(text, "\n")[[1]]

  # Detect list items
  for (i in seq_along(lines)) {
    line <- lines[i]

    # Numbered lists
    if (grepl("^\\s*\\d+\\.\\s+", line)) {
      lines[i] <- gsub("^\\s*", "", line)
    }

    # Bullet lists (fix inconsistent bullets)
    if (grepl("^\\s*[-*+]\\s+", line)) {
      lines[i] <- gsub("^\\s*[-*+]\\s+", "- ", line)
    }
  }

  text <- paste(lines, collapse = "\n")
  return(text)
}

#' Optimize Response Length
#'
#' Trim or expand response to optimal length
#'
#' @param text Character string. Response text
#' @param target_length Character. Target length: "concise", "normal", "detailed" (default: "normal")
#' @return Character string with optimized length
optimize_length <- function(text, target_length = "normal") {
  word_count <- length(unlist(strsplit(text, "\\s+")))

  if (target_length == "concise" && word_count > 150) {
    # Trim to first 150 words
    words <- unlist(strsplit(text, "\\s+"))
    text <- paste(words[1:min(150, length(words))], collapse = " ")
    text <- paste0(text, "...")
  } else if (target_length == "detailed" && word_count < 100) {
    # Add note suggesting more detail
    text <- paste0(text, "\n\n*Note: This response is relatively brief. Consider asking for more specific details if needed.*")
  }

  return(text)
}

#' Check Response Quality
#'
#' Evaluate response quality metrics
#'
#' @param text Character string. Response to evaluate
#' @return List with quality metrics
check_response_quality <- function(text) {
  word_count <- length(unlist(strsplit(text, "\\s+")))
  sentence_count <- length(unlist(strsplit(text, "[.!?]+")))
  paragraph_count <- length(unlist(strsplit(text, "\n\n+")))

  has_code <- detect_code_blocks(text)$has_code
  has_lists <- grepl("^\\s*[-*+]\\s+|^\\s*\\d+\\.\\s+", text, perl = TRUE)
  has_headings <- grepl("^#{1,6}\\s+", text, perl = TRUE, useBytes = TRUE)

  # Calculate readability (approximate)
  avg_words_per_sentence <- if (sentence_count > 0) word_count / sentence_count else 0

  readability <- if (avg_words_per_sentence < 15) {
    "Easy"
  } else if (avg_words_per_sentence < 25) {
    "Moderate"
  } else {
    "Complex"
  }

  quality <- list(
    word_count = word_count,
    sentence_count = sentence_count,
    paragraph_count = paragraph_count,
    avg_words_per_sentence = round(avg_words_per_sentence, 1),
    readability = readability,
    has_code = has_code,
    has_lists = has_lists,
    has_headings = has_headings,
    structure_score = calculate_structure_score(text)
  )

  return(quality)
}

#' Calculate Structure Score
#'
#' Calculate a score for text structure quality
#'
#' @param text Character string. Text to evaluate
#' @return Numeric score (0-100)
calculate_structure_score <- function(text) {
  score <- 0

  # Check for paragraphs
  if (grepl("\n\n", text)) score <- score + 25

  # Check for lists
  if (grepl("^\\s*[-*+]\\s+|^\\s*\\d+\\.\\s+", text, perl = TRUE)) score <- score + 20

  # Check for headings
  if (grepl("^#{1,6}\\s+", text, perl = TRUE, useBytes = TRUE)) score <- score + 20

  # Check for code blocks
  if (grepl("```", text)) score <- score + 20

  # Check for proper punctuation
  if (grepl("[.!?]$", text)) score <- score + 15

  return(min(score, 100))
}

#' Process AI Response
#'
#' Apply all response processing enhancements
#'
#' @param text Character string. Raw AI response
#' @param options List. Processing options
#' @return Character string with processed response
#' @export
#' @examples
#' \dontrun{
#' processed <- process_response(
#'   text = raw_response,
#'   options = list(
#'     format_code = TRUE,
#'     highlight_terms = TRUE,
#'     optimize_length = "normal"
#'   )
#' )
#' }
process_response <- function(text, options = list()) {
  # Default options
  default_options <- list(
    format_code = TRUE,
    highlight_terms = TRUE,
    structure_text = TRUE,
    format_lists = TRUE,
    optimize_length = "normal"
  )

  # Merge with provided options
  options <- modifyList(default_options, options)

  # Apply processing steps
  if (options$structure_text) {
    text <- structure_text(text)
  }

  if (options$format_lists) {
    text <- format_lists(text)
  }

  if (options$format_code) {
    text <- format_code_blocks(text)
  }

  if (options$highlight_terms) {
    terms <- detect_technical_terms(text)
    # Limit highlighting to avoid over-formatting
    if (length(terms) > 0 && length(terms) <= 20) {
      text <- highlight_technical_terms(text, terms)
    }
  }

  if (!is.null(options$optimize_length)) {
    text <- optimize_length(text, options$optimize_length)
  }

  return(text)
}

#' Add Response Metadata
#'
#' Add metadata header to response
#'
#' @param text Character string. Response text
#' @param metadata List. Metadata to include
#' @return Character string with metadata header
#' @export
add_response_metadata <- function(text, metadata = list()) {
  if (length(metadata) == 0) {
    return(text)
  }

  header_parts <- c()

  if (!is.null(metadata$model)) {
    header_parts <- c(header_parts, paste("Model:", metadata$model))
  }

  if (!is.null(metadata$tokens)) {
    header_parts <- c(header_parts, paste("Tokens:", metadata$tokens))
  }

  if (!is.null(metadata$duration)) {
    header_parts <- c(header_parts, paste("Duration:", round(metadata$duration, 2), "s"))
  }

  if (length(header_parts) > 0) {
    header <- paste0("*", paste(header_parts, collapse = " | "), "*\n\n---\n\n")
    text <- paste0(header, text)
  }

  return(text)
}

#' Format Response for Display
#'
#' Final formatting for display in UI
#'
#' @param text Character string. Response text
#' @param format Character. Output format: "html", "markdown", "plain" (default: "markdown")
#' @return Character string formatted for display
#' @export
format_response_display <- function(text, format = "markdown") {
  if (format == "html") {
    # Convert markdown to HTML if needed
    if (requireNamespace("markdown", quietly = TRUE)) {
      text <- markdown::markdownToHTML(text = text, fragment.only = TRUE)
    }
  } else if (format == "plain") {
    # Remove markdown formatting
    text <- gsub("```[a-z]*\\n", "", text)
    text <- gsub("```", "", text)
    text <- gsub("\\*\\*([^*]+)\\*\\*", "\\1", text)
    text <- gsub("\\*([^*]+)\\*", "\\1", text)
    text <- gsub("`([^`]+)`", "\\1", text)
  }

  return(text)
}

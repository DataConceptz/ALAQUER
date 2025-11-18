#' Check Ollama Connection
#'
#' Test connectivity to an Ollama instance
#'
#' @param host Character string. Ollama host URL (default: "http://localhost:11434")
#' @return Logical. TRUE if connection successful, FALSE otherwise
#' @export
#' @examples
#' \dontrun{
#' check_ollama_connection("http://localhost:11434")
#' }
check_ollama_connection <- function(host = "http://localhost:11434") {
  tryCatch({
    response <- httr::GET(paste0(host, "/api/tags"))
    return(httr::status_code(response) == 200)
  }, error = function(e) {
    return(FALSE)
  })
}

#' Get Available Ollama Models
#'
#' Retrieve list of available models from Ollama instance
#'
#' @param host Character string. Ollama host URL (default: "http://localhost:11434")
#' @return Character vector of model names, or NULL if error
#' @export
#' @examples
#' \dontrun{
#' models <- get_ollama_models("http://localhost:11434")
#' }
get_ollama_models <- function(host = "http://localhost:11434") {
  tryCatch({
    response <- httr::GET(paste0(host, "/api/tags"))

    if (httr::status_code(response) != 200) {
      warning("Failed to retrieve models from Ollama")
      return(NULL)
    }

    content <- httr::content(response, as = "parsed")

    if (is.null(content$models) || length(content$models) == 0) {
      return(NULL)
    }

    models <- sapply(content$models, function(m) m$name)
    return(models)

  }, error = function(e) {
    warning(paste("Error connecting to Ollama:", e$message))
    return(NULL)
  })
}

#' Query Ollama Model
#'
#' Send a query to an Ollama model and receive a response
#'
#' @param prompt Character string. The query/prompt to send
#' @param model Character string. Name of the Ollama model to use
#' @param host Character string. Ollama host URL (default: "http://localhost:11434")
#' @param temperature Numeric. Controls randomness (0-2, default: 0.7)
#' @param top_p Numeric. Controls diversity (0-1, default: 0.9)
#' @param max_tokens Integer. Maximum response length (default: 2000)
#' @param context Character vector. Previous conversation context (optional)
#' @param stream Logical. Whether to stream the response (default: FALSE)
#' @return List containing response text and metadata, or NULL if error
#' @export
#' @examples
#' \dontrun{
#' response <- ollama_query(
#'   prompt = "What is machine learning?",
#'   model = "llama2",
#'   temperature = 0.7
#' )
#' }
ollama_query <- function(prompt,
                        model,
                        host = "http://localhost:11434",
                        temperature = 0.7,
                        top_p = 0.9,
                        max_tokens = 2000,
                        context = NULL,
                        stream = FALSE) {

  tryCatch({
    # Build request body
    body <- list(
      model = model,
      prompt = prompt,
      stream = stream,
      options = list(
        temperature = temperature,
        top_p = top_p,
        num_predict = max_tokens
      )
    )

    # Add context if provided
    if (!is.null(context)) {
      body$context <- context
    }

    # Send POST request
    response <- httr::POST(
      url = paste0(host, "/api/generate"),
      body = jsonlite::toJSON(body, auto_unbox = TRUE),
      httr::add_headers("Content-Type" = "application/json"),
      encode = "raw"
    )

    if (httr::status_code(response) != 200) {
      warning(paste("Ollama API returned status:", httr::status_code(response)))
      return(NULL)
    }

    # Parse response
    content <- httr::content(response, as = "text", encoding = "UTF-8")
    result <- jsonlite::fromJSON(content)

    return(list(
      text = result$response,
      model = result$model,
      context = result$context,
      done = result$done,
      total_duration = result$total_duration,
      eval_count = result$eval_count
    ))

  }, error = function(e) {
    warning(paste("Error querying Ollama:", e$message))
    return(NULL)
  })
}

#' Query Ollama with Streaming
#'
#' Send a query to Ollama and receive streaming response
#'
#' @param prompt Character string. The query/prompt to send
#' @param model Character string. Name of the Ollama model to use
#' @param host Character string. Ollama host URL (default: "http://localhost:11434")
#' @param temperature Numeric. Controls randomness (0-2, default: 0.7)
#' @param top_p Numeric. Controls diversity (0-1, default: 0.9)
#' @param max_tokens Integer. Maximum response length (default: 2000)
#' @param context Character vector. Previous conversation context (optional)
#' @param callback Function. Callback function to handle each chunk (optional)
#' @return List containing full response text and metadata
#' @export
ollama_query_stream <- function(prompt,
                               model,
                               host = "http://localhost:11434",
                               temperature = 0.7,
                               top_p = 0.9,
                               max_tokens = 2000,
                               context = NULL,
                               callback = NULL) {

  tryCatch({
    # Build request body
    body <- list(
      model = model,
      prompt = prompt,
      stream = TRUE,
      options = list(
        temperature = temperature,
        top_p = top_p,
        num_predict = max_tokens
      )
    )

    if (!is.null(context)) {
      body$context <- context
    }

    # Initialize variables for streaming
    full_response <- ""
    final_context <- NULL

    # Send POST request with streaming
    response <- httr::POST(
      url = paste0(host, "/api/generate"),
      body = jsonlite::toJSON(body, auto_unbox = TRUE),
      httr::add_headers("Content-Type" = "application/json"),
      encode = "raw"
    )

    if (httr::status_code(response) != 200) {
      warning(paste("Ollama API returned status:", httr::status_code(response)))
      return(NULL)
    }

    # Parse streaming response
    content <- httr::content(response, as = "text", encoding = "UTF-8")
    lines <- strsplit(content, "\n")[[1]]

    for (line in lines) {
      if (nchar(line) > 0) {
        chunk <- jsonlite::fromJSON(line)

        if (!is.null(chunk$response)) {
          full_response <- paste0(full_response, chunk$response)

          # Call callback if provided
          if (!is.null(callback)) {
            callback(chunk$response)
          }
        }

        if (!is.null(chunk$context)) {
          final_context <- chunk$context
        }
      }
    }

    return(list(
      text = full_response,
      model = model,
      context = final_context,
      done = TRUE
    ))

  }, error = function(e) {
    warning(paste("Error in streaming query:", e$message))
    return(NULL)
  })
}

#' Pull Ollama Model
#'
#' Download a model from Ollama library
#'
#' @param model Character string. Name of model to pull
#' @param host Character string. Ollama host URL (default: "http://localhost:11434")
#' @return Logical. TRUE if successful, FALSE otherwise
#' @export
pull_ollama_model <- function(model, host = "http://localhost:11434") {
  tryCatch({
    body <- list(name = model)

    response <- httr::POST(
      url = paste0(host, "/api/pull"),
      body = jsonlite::toJSON(body, auto_unbox = TRUE),
      httr::add_headers("Content-Type" = "application/json"),
      encode = "raw"
    )

    return(httr::status_code(response) == 200)

  }, error = function(e) {
    warning(paste("Error pulling model:", e$message))
    return(FALSE)
  })
}

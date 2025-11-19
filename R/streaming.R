#' Streaming Response System
#'
#' Handle streaming responses from Ollama for real-time display
#'
#' @name streaming
NULL

#' Stream Ollama Response
#'
#' Get streaming response from Ollama with real-time token generation
#'
#' @param prompt Character string. The query/prompt
#' @param model Character string. Ollama model name
#' @param host Character string. Ollama host URL
#' @param temperature Numeric. Temperature parameter
#' @param top_p Numeric. Top P parameter
#' @param max_tokens Integer. Maximum tokens
#' @param context Character vector. Previous context (optional)
#' @param callback Function. Called for each token chunk
#' @return List with complete response and metadata
#' @export
stream_ollama_response <- function(prompt,
                                   model,
                                   host = "http://localhost:11434",
                                   temperature = 0.7,
                                   top_p = 0.9,
                                   max_tokens = 2000,
                                   context = NULL,
                                   callback = NULL) {

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

  # Initialize streaming variables
  full_response <- ""
  final_context <- NULL
  token_count <- 0
  start_time <- Sys.time()

  tryCatch({
    # Create curl handle for streaming
    h <- curl::new_handle()
    curl::handle_setopt(h, customrequest = "POST")
    curl::handle_setheaders(h, "Content-Type" = "application/json")
    curl::handle_setopt(h, postfields = jsonlite::toJSON(body, auto_unbox = TRUE))

    # Stream the response
    curl::curl_fetch_stream(
      paste0(host, "/api/generate"),
      function(x) {
        # Parse each JSON line
        lines <- strsplit(rawToChar(x), "\n")[[1]]

        for (line in lines) {
          if (nchar(line) > 0) {
            chunk <- tryCatch(
              jsonlite::fromJSON(line),
              error = function(e) NULL
            )

            if (!is.null(chunk) && !is.null(chunk$response)) {
              # Append to full response
              full_response <<- paste0(full_response, chunk$response)
              token_count <<- token_count + 1

              # Call callback with new token
              if (!is.null(callback)) {
                callback(chunk$response, full_response, token_count)
              }

              # Store final context
              if (!is.null(chunk$context)) {
                final_context <<- chunk$context
              }
            }
          }
        }

        TRUE  # Continue streaming
      },
      handle = h
    )

    end_time <- Sys.time()
    duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

    return(list(
      text = full_response,
      model = model,
      context = final_context,
      done = TRUE,
      token_count = token_count,
      duration = duration,
      tokens_per_second = if (duration > 0) token_count / duration else 0
    ))

  }, error = function(e) {
    warning(paste("Error in streaming:", e$message))
    return(list(
      text = full_response,
      model = model,
      error = e$message,
      done = FALSE
    ))
  })
}

#' Create Streaming Session
#'
#' Create a persistent streaming session for multiple queries
#'
#' @param model Character string. Model name
#' @param host Character string. Ollama host
#' @return List with session data
#' @export
create_streaming_session <- function(model, host = "http://localhost:11434") {
  list(
    model = model,
    host = host,
    context = NULL,
    message_history = list(),
    created = Sys.time()
  )
}

#' Stream with Session Context
#'
#' Stream response while maintaining session context
#'
#' @param session List. Streaming session
#' @param prompt Character string. User prompt
#' @param callback Function. Token callback
#' @param temperature Numeric. Temperature
#' @param top_p Numeric. Top P
#' @param max_tokens Integer. Max tokens
#' @return Updated session with response
#' @export
stream_with_session <- function(session,
                                prompt,
                                callback = NULL,
                                temperature = 0.7,
                                top_p = 0.9,
                                max_tokens = 2000) {

  # Stream response
  result <- stream_ollama_response(
    prompt = prompt,
    model = session$model,
    host = session$host,
    temperature = temperature,
    top_p = top_p,
    max_tokens = max_tokens,
    context = session$context,
    callback = callback
  )

  # Update session
  session$context <- result$context
  session$message_history[[length(session$message_history) + 1]] <- list(
    type = "user",
    content = prompt,
    timestamp = Sys.time()
  )
  session$message_history[[length(session$message_history) + 1]] <- list(
    type = "ai",
    content = result$text,
    timestamp = Sys.time(),
    tokens = result$token_count,
    duration = result$duration
  )

  return(session)
}

#' Estimate Streaming Time
#'
#' Estimate how long streaming will take based on prompt length
#'
#' @param prompt Character string. The prompt
#' @param model Character string. Model name
#' @param avg_tokens_per_second Numeric. Average speed (default: 20)
#' @return Numeric. Estimated seconds
#' @export
estimate_streaming_time <- function(prompt,
                                    model = NULL,
                                    avg_tokens_per_second = 20) {

  # Rough estimate: 1.3 tokens per word
  words <- length(unlist(strsplit(prompt, "\\s+")))
  estimated_prompt_tokens <- words * 1.3

  # Assume response will be similar length
  estimated_response_tokens <- estimated_prompt_tokens * 1.5

  # Calculate time
  estimated_seconds <- estimated_response_tokens / avg_tokens_per_second

  return(max(1, estimated_seconds))  # At least 1 second
}

#' Format Streaming Progress
#'
#' Create progress message for streaming
#'
#' @param current_tokens Integer. Tokens received so far
#' @param elapsed_seconds Numeric. Time elapsed
#' @param estimated_total Numeric. Estimated total time (optional)
#' @return Character string with formatted progress
#' @export
format_streaming_progress <- function(current_tokens,
                                      elapsed_seconds,
                                      estimated_total = NULL) {

  tokens_per_sec <- if (elapsed_seconds > 0) {
    current_tokens / elapsed_seconds
  } else {
    0
  }

  msg <- sprintf(
    "Streaming... %d tokens (%.1f tok/s)",
    current_tokens,
    tokens_per_sec
  )

  if (!is.null(estimated_total) && estimated_total > 0) {
    percent <- min(100, (elapsed_seconds / estimated_total) * 100)
    msg <- paste0(msg, sprintf(" - %.0f%% complete", percent))
  }

  return(msg)
}

#' Cancel Streaming
#'
#' Cancel an ongoing streaming operation
#'
#' @param session List. Streaming session
#' @return Logical. TRUE if cancelled
#' @export
cancel_streaming <- function(session) {
  # In practice, this would interrupt the curl connection
  # For now, just mark session as cancelled
  session$cancelled <- TRUE
  session$cancelled_at <- Sys.time()
  return(TRUE)
}

#' Batch Stream Multiple Prompts
#'
#' Stream responses for multiple prompts sequentially
#'
#' @param prompts Character vector. Multiple prompts
#' @param model Character string. Model name
#' @param host Character string. Ollama host
#' @param callback Function. Called for each prompt completion
#' @param delay Numeric. Delay between prompts in seconds (default: 0.5)
#' @return List of responses
#' @export
batch_stream_prompts <- function(prompts,
                                 model,
                                 host = "http://localhost:11434",
                                 callback = NULL,
                                 delay = 0.5) {

  results <- list()

  for (i in seq_along(prompts)) {
    message(paste("Processing prompt", i, "of", length(prompts)))

    result <- stream_ollama_response(
      prompt = prompts[i],
      model = model,
      host = host
    )

    results[[i]] <- result

    if (!is.null(callback)) {
      callback(i, result)
    }

    # Delay between prompts
    if (i < length(prompts) && delay > 0) {
      Sys.sleep(delay)
    }
  }

  return(results)
}

#' Stream with Token Limit
#'
#' Stream response but stop after certain number of tokens
#'
#' @param prompt Character string. The prompt
#' @param model Character string. Model name
#' @param host Character string. Host URL
#' @param token_limit Integer. Maximum tokens to stream
#' @param callback Function. Token callback
#' @return List with response
#' @export
stream_with_limit <- function(prompt,
                              model,
                              host = "http://localhost:11434",
                              token_limit = 100,
                              callback = NULL) {

  token_count <- 0
  full_response <- ""
  stopped_early <- FALSE

  limited_callback <- function(token, full_text, count) {
    token_count <<- count

    if (!is.null(callback)) {
      callback(token, full_text, count)
    }

    # Check if we should stop
    if (count >= token_limit) {
      stopped_early <<- TRUE
      stop("Token limit reached")  # This will stop the stream
    }
  }

  result <- tryCatch({
    stream_ollama_response(
      prompt = prompt,
      model = model,
      host = host,
      callback = limited_callback
    )
  }, error = function(e) {
    if (stopped_early) {
      list(
        text = full_response,
        model = model,
        stopped_early = TRUE,
        token_count = token_count
      )
    } else {
      NULL
    }
  })

  return(result)
}

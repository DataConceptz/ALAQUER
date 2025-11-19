#' Performance Optimization System
#'
#' Advanced caching, parallel processing, and performance monitoring for ALAQUER.
#'
#' @name performance
NULL

# Cache environment for storing responses
.alaquer_cache <- new.env(parent = emptyenv())
.alaquer_performance_metrics <- new.env(parent = emptyenv())

#' Create Response Cache
#'
#' Initialize a caching system for Ollama responses with TTL support.
#'
#' @param max_size Maximum number of cached items (default: 100)
#' @param ttl Time-to-live in seconds (default: 3600 = 1 hour)
#' @return Cache configuration list
#' @export
create_cache <- function(max_size = 100, ttl = 3600) {
  cache_config <- list(
    max_size = max_size,
    ttl = ttl,
    created = Sys.time()
  )

  assign("cache_config", cache_config, envir = .alaquer_cache)
  assign("cache_data", list(), envir = .alaquer_cache)
  assign("cache_metadata", list(), envir = .alaquer_cache)

  message("Cache initialized: max_size=", max_size, ", ttl=", ttl, "s")
  invisible(cache_config)
}

#' Cache Key Generator
#'
#' Generate a unique cache key from query parameters.
#'
#' @param prompt User prompt
#' @param model Model name
#' @param temperature Temperature parameter
#' @param ... Additional parameters
#' @return Cache key string
#' @export
generate_cache_key <- function(prompt, model, temperature = 0.7, ...) {
  params <- list(
    prompt = prompt,
    model = model,
    temperature = temperature,
    ...
  )

  # Create hash of parameters
  key_string <- paste(names(params), params, sep = "=", collapse = "|")
  cache_key <- digest::digest(key_string, algo = "md5")

  return(cache_key)
}

#' Get Cached Response
#'
#' Retrieve a cached response if available and not expired.
#'
#' @param cache_key Cache key to lookup
#' @return Cached response or NULL if not found/expired
#' @export
get_cached_response <- function(cache_key) {
  if (!exists("cache_data", envir = .alaquer_cache)) {
    return(NULL)
  }

  cache_data <- get("cache_data", envir = .alaquer_cache)
  cache_metadata <- get("cache_metadata", envir = .alaquer_cache)
  cache_config <- get("cache_config", envir = .alaquer_cache)

  if (!cache_key %in% names(cache_data)) {
    return(NULL)
  }

  # Check if expired
  cached_time <- cache_metadata[[cache_key]]$timestamp
  age <- as.numeric(difftime(Sys.time(), cached_time, units = "secs"))

  if (age > cache_config$ttl) {
    # Remove expired entry
    cache_data[[cache_key]] <- NULL
    cache_metadata[[cache_key]] <- NULL
    assign("cache_data", cache_data, envir = .alaquer_cache)
    assign("cache_metadata", cache_metadata, envir = .alaquer_cache)
    return(NULL)
  }

  # Update hit count
  cache_metadata[[cache_key]]$hits <- cache_metadata[[cache_key]]$hits + 1
  cache_metadata[[cache_key]]$last_accessed <- Sys.time()
  assign("cache_metadata", cache_metadata, envir = .alaquer_cache)

  message("Cache hit: ", cache_key)
  return(cache_data[[cache_key]])
}

#' Set Cached Response
#'
#' Store a response in the cache with metadata.
#'
#' @param cache_key Cache key
#' @param response Response to cache
#' @return TRUE if successful
#' @export
set_cached_response <- function(cache_key, response) {
  if (!exists("cache_data", envir = .alaquer_cache)) {
    create_cache()
  }

  cache_data <- get("cache_data", envir = .alaquer_cache)
  cache_metadata <- get("cache_metadata", envir = .alaquer_cache)
  cache_config <- get("cache_config", envir = .alaquer_cache)

  # Implement LRU eviction if cache is full
  if (length(cache_data) >= cache_config$max_size) {
    # Find least recently used item
    access_times <- sapply(cache_metadata, function(m) m$last_accessed)
    oldest_key <- names(which.min(access_times))
    cache_data[[oldest_key]] <- NULL
    cache_metadata[[oldest_key]] <- NULL
    message("Cache eviction (LRU): ", oldest_key)
  }

  # Store response and metadata
  cache_data[[cache_key]] <- response
  cache_metadata[[cache_key]] <- list(
    timestamp = Sys.time(),
    last_accessed = Sys.time(),
    hits = 0,
    size = object.size(response)
  )

  assign("cache_data", cache_data, envir = .alaquer_cache)
  assign("cache_metadata", cache_metadata, envir = .alaquer_cache)

  message("Cached response: ", cache_key)
  invisible(TRUE)
}

#' Clear Cache
#'
#' Clear all cached responses or specific keys.
#'
#' @param pattern Optional regex pattern to match keys (default: NULL clears all)
#' @return Number of items cleared
#' @export
clear_cache <- function(pattern = NULL) {
  if (!exists("cache_data", envir = .alaquer_cache)) {
    return(0)
  }

  cache_data <- get("cache_data", envir = .alaquer_cache)
  cache_metadata <- get("cache_metadata", envir = .alaquer_cache)

  if (is.null(pattern)) {
    # Clear all
    count <- length(cache_data)
    assign("cache_data", list(), envir = .alaquer_cache)
    assign("cache_metadata", list(), envir = .alaquer_cache)
    message("Cleared all cache (", count, " items)")
    return(count)
  } else {
    # Clear matching keys
    matching_keys <- grep(pattern, names(cache_data), value = TRUE)
    for (key in matching_keys) {
      cache_data[[key]] <- NULL
      cache_metadata[[key]] <- NULL
    }
    assign("cache_data", cache_data, envir = .alaquer_cache)
    assign("cache_metadata", cache_metadata, envir = .alaquer_cache)
    message("Cleared ", length(matching_keys), " cache items matching '", pattern, "'")
    return(length(matching_keys))
  }
}

#' Get Cache Statistics
#'
#' Get detailed statistics about cache usage.
#'
#' @return List with cache statistics
#' @export
get_cache_stats <- function() {
  if (!exists("cache_data", envir = .alaquer_cache)) {
    return(list(
      size = 0,
      total_hits = 0,
      total_size_bytes = 0,
      items = list()
    ))
  }

  cache_data <- get("cache_data", envir = .alaquer_cache)
  cache_metadata <- get("cache_metadata", envir = .alaquer_cache)
  cache_config <- get("cache_config", envir = .alaquer_cache)

  total_hits <- sum(sapply(cache_metadata, function(m) m$hits))
  total_size <- sum(sapply(cache_metadata, function(m) as.numeric(m$size)))

  stats <- list(
    size = length(cache_data),
    max_size = cache_config$ttl,
    ttl_seconds = cache_config$ttl,
    total_hits = total_hits,
    total_size_bytes = total_size,
    total_size_mb = round(total_size / 1024^2, 2),
    items = lapply(names(cache_metadata), function(key) {
      list(
        key = key,
        hits = cache_metadata[[key]]$hits,
        age_seconds = as.numeric(difftime(Sys.time(), cache_metadata[[key]]$timestamp, units = "secs")),
        size_bytes = as.numeric(cache_metadata[[key]]$size)
      )
    })
  )

  return(stats)
}

#' Parallel Model Query
#'
#' Query multiple models in parallel and return all responses.
#'
#' @param prompt User prompt
#' @param models Vector of model names
#' @param host Ollama host (default: "http://localhost:11434")
#' @param temperature Temperature parameter (default: 0.7)
#' @param use_cache Whether to use caching (default: TRUE)
#' @param max_workers Maximum parallel workers (default: 4)
#' @return Data frame with model responses
#' @export
parallel_model_query <- function(prompt, models, host = "http://localhost:11434",
                                  temperature = 0.7, use_cache = TRUE, max_workers = 4) {

  start_time <- Sys.time()

  # Check for parallel package
  if (!requireNamespace("parallel", quietly = TRUE)) {
    warning("parallel package not available, falling back to sequential execution")
    results <- lapply(models, function(model) {
      query_with_cache(prompt, model, host, temperature, use_cache)
    })
  } else {
    # Limit workers
    n_cores <- min(length(models), max_workers, parallel::detectCores() - 1)

    message("Querying ", length(models), " models in parallel (", n_cores, " workers)")

    # Create cluster
    cl <- parallel::makeCluster(n_cores)

    # Export necessary functions and variables
    parallel::clusterExport(cl, c("prompt", "host", "temperature", "use_cache"),
                            envir = environment())

    tryCatch({
      results <- parallel::parLapply(cl, models, function(model) {
        query_with_cache(prompt, model, host, temperature, use_cache)
      })
    }, finally = {
      parallel::stopCluster(cl)
    })
  }

  # Combine results
  df <- do.call(rbind, lapply(seq_along(models), function(i) {
    result <- results[[i]]
    data.frame(
      model = models[i],
      response = if (!is.null(result$response)) result$response else NA_character_,
      duration_sec = if (!is.null(result$duration)) result$duration else NA_real_,
      cached = if (!is.null(result$cached)) result$cached else FALSE,
      error = if (!is.null(result$error)) result$error else NA_character_,
      stringsAsFactors = FALSE
    )
  }))

  total_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  message("Parallel query complete in ", round(total_time, 2), "s")

  attr(df, "total_duration") <- total_time
  attr(df, "parallel_speedup") <- sum(df$duration_sec, na.rm = TRUE) / total_time

  return(df)
}

#' Query with Cache
#'
#' Internal function to query Ollama with cache support.
#'
#' @keywords internal
query_with_cache <- function(prompt, model, host, temperature, use_cache) {
  start_time <- Sys.time()

  # Generate cache key
  cache_key <- generate_cache_key(prompt, model, temperature)

  # Try cache first
  if (use_cache) {
    cached <- get_cached_response(cache_key)
    if (!is.null(cached)) {
      return(list(
        response = cached$response,
        duration = cached$duration,
        cached = TRUE
      ))
    }
  }

  # Query Ollama
  tryCatch({
    # Assuming ollama_query function exists from ollama_integration.R
    result <- ollama_query(prompt, model, host, temperature)
    duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

    response_data <- list(
      response = result,
      duration = duration,
      cached = FALSE
    )

    # Cache the response
    if (use_cache) {
      set_cached_response(cache_key, response_data)
    }

    return(response_data)
  }, error = function(e) {
    return(list(
      response = NULL,
      duration = NULL,
      cached = FALSE,
      error = as.character(e$message)
    ))
  })
}

#' Memoize Function
#'
#' Create a memoized version of a function that caches results.
#'
#' @param func Function to memoize
#' @param cache_size Maximum cache size (default: 50)
#' @return Memoized function
#' @export
memoize <- function(func, cache_size = 50) {
  cache <- new.env(parent = emptyenv())
  cache$data <- list()
  cache$max_size <- cache_size

  function(...) {
    # Create key from arguments
    args <- list(...)
    key <- digest::digest(args, algo = "md5")

    # Check cache
    if (key %in% names(cache$data)) {
      return(cache$data[[key]])
    }

    # Compute result
    result <- func(...)

    # Store in cache with LRU eviction
    if (length(cache$data) >= cache$max_size) {
      cache$data[[1]] <- NULL
    }
    cache$data[[key]] <- result

    return(result)
  }
}

#' Start Performance Monitoring
#'
#' Begin tracking performance metrics for ALAQUER operations.
#'
#' @return Monitoring session ID
#' @export
start_performance_monitoring <- function() {
  session_id <- digest::digest(Sys.time(), algo = "md5")

  metrics <- list(
    session_id = session_id,
    start_time = Sys.time(),
    queries = list(),
    cache_hits = 0,
    cache_misses = 0
  )

  assign(session_id, metrics, envir = .alaquer_performance_metrics)

  message("Performance monitoring started: ", session_id)
  invisible(session_id)
}

#' Record Query Metric
#'
#' Record performance metrics for a query.
#'
#' @param session_id Monitoring session ID
#' @param operation Operation name
#' @param duration Duration in seconds
#' @param cached Whether result was cached
#' @param ... Additional metadata
#' @export
record_query_metric <- function(session_id, operation, duration, cached = FALSE, ...) {
  if (!exists(session_id, envir = .alaquer_performance_metrics)) {
    warning("Monitoring session not found: ", session_id)
    return(invisible(NULL))
  }

  metrics <- get(session_id, envir = .alaquer_performance_metrics)

  query_metric <- list(
    timestamp = Sys.time(),
    operation = operation,
    duration = duration,
    cached = cached,
    ...
  )

  metrics$queries <- c(metrics$queries, list(query_metric))

  if (cached) {
    metrics$cache_hits <- metrics$cache_hits + 1
  } else {
    metrics$cache_misses <- metrics$cache_misses + 1
  }

  assign(session_id, metrics, envir = .alaquer_performance_metrics)
  invisible(NULL)
}

#' Get Performance Report
#'
#' Generate a comprehensive performance report.
#'
#' @param session_id Monitoring session ID
#' @return Performance report list
#' @export
get_performance_report <- function(session_id) {
  if (!exists(session_id, envir = .alaquer_performance_metrics)) {
    stop("Monitoring session not found: ", session_id)
  }

  metrics <- get(session_id, envir = .alaquer_performance_metrics)

  total_queries <- length(metrics$queries)
  if (total_queries == 0) {
    return(list(
      session_id = session_id,
      total_queries = 0,
      message = "No queries recorded"
    ))
  }

  durations <- sapply(metrics$queries, function(q) q$duration)
  operations <- sapply(metrics$queries, function(q) q$operation)

  report <- list(
    session_id = session_id,
    start_time = metrics$start_time,
    end_time = Sys.time(),
    session_duration = as.numeric(difftime(Sys.time(), metrics$start_time, units = "secs")),
    total_queries = total_queries,
    cache_hit_rate = if (total_queries > 0) {
      round(metrics$cache_hits / total_queries * 100, 2)
    } else 0,
    cache_hits = metrics$cache_hits,
    cache_misses = metrics$cache_misses,
    avg_duration = mean(durations),
    median_duration = median(durations),
    min_duration = min(durations),
    max_duration = max(durations),
    total_duration = sum(durations),
    operations = table(operations),
    queries = metrics$queries
  )

  class(report) <- c("alaquer_performance_report", "list")
  return(report)
}

#' Print Performance Report
#'
#' @param x Performance report object
#' @param ... Additional arguments
#' @export
print.alaquer_performance_report <- function(x, ...) {
  cat("ALAQUER Performance Report\n")
  cat("==========================\n")
  cat("Session ID:", x$session_id, "\n")
  cat("Duration:", round(x$session_duration, 2), "seconds\n")
  cat("\nQuery Statistics:\n")
  cat("  Total queries:", x$total_queries, "\n")
  cat("  Cache hit rate:", x$cache_hit_rate, "%\n")
  cat("  Cache hits:", x$cache_hits, "\n")
  cat("  Cache misses:", x$cache_misses, "\n")
  cat("\nTiming Statistics:\n")
  cat("  Average:", round(x$avg_duration, 3), "s\n")
  cat("  Median:", round(x$median_duration, 3), "s\n")
  cat("  Min:", round(x$min_duration, 3), "s\n")
  cat("  Max:", round(x$max_duration, 3), "s\n")
  cat("  Total:", round(x$total_duration, 2), "s\n")
  cat("\nOperations:\n")
  print(x$operations)
  invisible(x)
}

#' Batch Process with Progress
#'
#' Process multiple items with parallel execution and progress tracking.
#'
#' @param items Vector of items to process
#' @param func Function to apply to each item
#' @param max_workers Maximum parallel workers (default: 4)
#' @param progress Whether to show progress (default: TRUE)
#' @return List of results
#' @export
batch_process <- function(items, func, max_workers = 4, progress = TRUE) {
  n_items <- length(items)

  if (n_items == 0) {
    return(list())
  }

  if (progress) {
    message("Processing ", n_items, " items with ", max_workers, " workers...")
  }

  start_time <- Sys.time()

  if (!requireNamespace("parallel", quietly = TRUE)) {
    # Sequential processing with progress
    results <- list()
    for (i in seq_along(items)) {
      if (progress && i %% 10 == 0) {
        cat("Progress:", round(i/n_items * 100, 1), "%\r")
        flush.console()
      }
      results[[i]] <- func(items[[i]])
    }
  } else {
    # Parallel processing
    n_cores <- min(max_workers, parallel::detectCores() - 1)
    cl <- parallel::makeCluster(n_cores)

    tryCatch({
      results <- parallel::parLapply(cl, items, func)
    }, finally = {
      parallel::stopCluster(cl)
    })
  }

  duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  if (progress) {
    message("\nCompleted ", n_items, " items in ", round(duration, 2), "s")
    message("Average: ", round(duration / n_items, 3), "s per item")
  }

  return(results)
}

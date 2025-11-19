#' Analytics and Insights Dashboard
#'
#' Track usage patterns, performance metrics, and generate actionable insights
#' for ALAQUER operations.
#'
#' @name analytics
NULL

# Analytics storage environment
.alaquer_analytics <- new.env(parent = emptyenv())

#' Initialize Analytics
#'
#' Set up analytics tracking system.
#'
#' @param storage_path Path to store analytics data (default: "~/.alaquer/analytics")
#' @param auto_save Whether to auto-save analytics (default: TRUE)
#' @param save_interval Save interval in seconds (default: 300)
#' @return Analytics configuration
#' @export
initialize_analytics <- function(storage_path = "~/.alaquer/analytics",
                                 auto_save = TRUE,
                                 save_interval = 300) {

  storage_path <- path.expand(storage_path)
  if (!dir.exists(storage_path)) {
    dir.create(storage_path, recursive = TRUE)
  }

  config <- list(
    storage_path = storage_path,
    auto_save = auto_save,
    save_interval = save_interval,
    initialized = Sys.time(),
    session_id = digest::digest(Sys.time(), algo = "md5")
  )

  # Initialize tracking data
  tracking_data <- list(
    queries = list(),
    models_used = list(),
    features_used = list(),
    errors = list(),
    performance_metrics = list(),
    user_ratings = list(),
    session_info = config
  )

  assign("config", config, envir = .alaquer_analytics)
  assign("tracking_data", tracking_data, envir = .alaquer_analytics)

  # Load historical data if exists
  historical_file <- file.path(storage_path, "analytics_history.rds")
  if (file.exists(historical_file)) {
    tryCatch({
      historical <- readRDS(historical_file)
      assign("historical_data", historical, envir = .alaquer_analytics)
      message("Loaded historical analytics data")
    }, error = function(e) {
      message("Could not load historical data: ", e$message)
      assign("historical_data", list(), envir = .alaquer_analytics)
    })
  } else {
    assign("historical_data", list(), envir = .alaquer_analytics)
  }

  message("Analytics initialized: ", config$session_id)
  invisible(config)
}

#' Track Query
#'
#' Record a query execution for analytics.
#'
#' @param prompt User prompt
#' @param model Model used
#' @param duration Execution duration in seconds
#' @param tokens Number of tokens (optional)
#' @param cached Whether result was cached
#' @param success Whether query succeeded
#' @param feature Feature used (optional)
#' @export
track_query <- function(prompt, model, duration, tokens = NULL, cached = FALSE,
                       success = TRUE, feature = "basic_query") {

  if (!exists("tracking_data", envir = .alaquer_analytics)) {
    initialize_analytics()
  }

  tracking_data <- get("tracking_data", envir = .alaquer_analytics)

  query_record <- list(
    timestamp = Sys.time(),
    prompt_length = nchar(prompt),
    prompt_preview = substr(prompt, 1, 100),
    model = model,
    duration = duration,
    tokens = tokens,
    cached = cached,
    success = success,
    feature = feature,
    session_id = tracking_data$session_info$session_id
  )

  tracking_data$queries <- c(tracking_data$queries, list(query_record))

  # Track model usage
  if (model %in% names(tracking_data$models_used)) {
    tracking_data$models_used[[model]]$count <- tracking_data$models_used[[model]]$count + 1
    tracking_data$models_used[[model]]$total_duration <- tracking_data$models_used[[model]]$total_duration + duration
  } else {
    tracking_data$models_used[[model]] <- list(count = 1, total_duration = duration)
  }

  # Track feature usage
  if (feature %in% names(tracking_data$features_used)) {
    tracking_data$features_used[[feature]] <- tracking_data$features_used[[feature]] + 1
  } else {
    tracking_data$features_used[[feature]] <- 1
  }

  assign("tracking_data", tracking_data, envir = .alaquer_analytics)

  # Auto-save if configured
  config <- get("config", envir = .alaquer_analytics)
  if (config$auto_save) {
    # Check if it's time to save
    last_save <- if (exists("last_save_time", envir = .alaquer_analytics)) {
      get("last_save_time", envir = .alaquer_analytics)
    } else {
      Sys.time() - config$save_interval - 1
    }

    if (as.numeric(difftime(Sys.time(), last_save, units = "secs")) >= config$save_interval) {
      save_analytics()
    }
  }

  invisible(NULL)
}

#' Track Error
#'
#' Record an error for analytics.
#'
#' @param error_message Error message
#' @param context Error context (function, operation, etc.)
#' @param severity Error severity ("low", "medium", "high")
#' @export
track_error <- function(error_message, context = "unknown", severity = "medium") {
  if (!exists("tracking_data", envir = .alaquer_analytics)) {
    initialize_analytics()
  }

  tracking_data <- get("tracking_data", envir = .alaquer_analytics)

  error_record <- list(
    timestamp = Sys.time(),
    message = error_message,
    context = context,
    severity = severity,
    session_id = tracking_data$session_info$session_id
  )

  tracking_data$errors <- c(tracking_data$errors, list(error_record))
  assign("tracking_data", tracking_data, envir = .alaquer_analytics)

  invisible(NULL)
}

#' Track User Rating
#'
#' Record user feedback/rating.
#'
#' @param rating Rating value (1-5)
#' @param feedback Optional text feedback
#' @param category Rating category
#' @export
track_user_rating <- function(rating, feedback = NULL, category = "general") {
  if (!exists("tracking_data", envir = .alaquer_analytics)) {
    initialize_analytics()
  }

  tracking_data <- get("tracking_data", envir = .alaquer_analytics)

  rating_record <- list(
    timestamp = Sys.time(),
    rating = rating,
    feedback = feedback,
    category = category,
    session_id = tracking_data$session_info$session_id
  )

  tracking_data$user_ratings <- c(tracking_data$user_ratings, list(rating_record))
  assign("tracking_data", tracking_data, envir = .alaquer_analytics)

  invisible(NULL)
}

#' Get Analytics Summary
#'
#' Generate comprehensive analytics summary.
#'
#' @param include_historical Include historical data (default: TRUE)
#' @return Analytics summary list
#' @export
get_analytics_summary <- function(include_historical = TRUE) {
  if (!exists("tracking_data", envir = .alaquer_analytics)) {
    return(list(message = "Analytics not initialized"))
  }

  tracking_data <- get("tracking_data", envir = .alaquer_analytics)
  queries <- tracking_data$queries

  if (length(queries) == 0) {
    return(list(
      message = "No queries tracked yet",
      session_id = tracking_data$session_info$session_id
    ))
  }

  # Query statistics
  durations <- sapply(queries, function(q) q$duration)
  success_count <- sum(sapply(queries, function(q) q$success))
  cached_count <- sum(sapply(queries, function(q) q$cached))

  # Model statistics
  models <- tracking_data$models_used
  most_used_model <- names(models)[which.max(sapply(models, function(m) m$count))]

  # Feature statistics
  features <- tracking_data$features_used
  most_used_feature <- names(features)[which.max(features)]

  # Error statistics
  errors <- tracking_data$errors
  error_count <- length(errors)

  # Rating statistics
  ratings <- tracking_data$user_ratings
  avg_rating <- if (length(ratings) > 0) {
    mean(sapply(ratings, function(r) r$rating))
  } else NA

  summary <- list(
    session_id = tracking_data$session_info$session_id,
    session_start = tracking_data$session_info$initialized,
    session_duration = as.numeric(difftime(Sys.time(), tracking_data$session_info$initialized, units = "mins")),

    # Query stats
    total_queries = length(queries),
    successful_queries = success_count,
    failed_queries = length(queries) - success_count,
    success_rate = round(success_count / length(queries) * 100, 2),
    cached_queries = cached_count,
    cache_hit_rate = round(cached_count / length(queries) * 100, 2),

    # Performance stats
    avg_duration = round(mean(durations), 3),
    median_duration = round(median(durations), 3),
    min_duration = round(min(durations), 3),
    max_duration = round(max(durations), 3),
    total_duration = round(sum(durations), 2),

    # Model stats
    models_used = length(models),
    most_used_model = most_used_model,
    model_breakdown = models,

    # Feature stats
    features_used = length(features),
    most_used_feature = most_used_feature,
    feature_breakdown = features,

    # Error stats
    total_errors = error_count,
    error_rate = if (length(queries) > 0) {
      round(error_count / length(queries) * 100, 2)
    } else 0,
    recent_errors = if (length(errors) > 0) tail(errors, 5) else list(),

    # User feedback
    total_ratings = length(ratings),
    average_rating = if (!is.na(avg_rating)) round(avg_rating, 2) else NA,
    recent_ratings = if (length(ratings) > 0) tail(ratings, 5) else list()
  )

  # Include historical data if requested
  if (include_historical && exists("historical_data", envir = .alaquer_analytics)) {
    historical <- get("historical_data", envir = .alaquer_analytics)
    if (length(historical) > 0) {
      summary$historical <- list(
        total_sessions = length(historical),
        total_historical_queries = sum(sapply(historical, function(h) h$total_queries))
      )
    }
  }

  class(summary) <- c("alaquer_analytics_summary", "list")
  return(summary)
}

#' Print Analytics Summary
#'
#' @param x Analytics summary object
#' @param ... Additional arguments
#' @export
print.alaquer_analytics_summary <- function(x, ...) {
  cat("====================================\n")
  cat("ALAQUER Analytics Summary\n")
  cat("====================================\n\n")

  cat("Session Information:\n")
  cat("  Session ID:", x$session_id, "\n")
  cat("  Duration:", round(x$session_duration, 1), "minutes\n\n")

  cat("Query Statistics:\n")
  cat("  Total queries:", x$total_queries, "\n")
  cat("  Success rate:", x$success_rate, "%\n")
  cat("  Cache hit rate:", x$cache_hit_rate, "%\n\n")

  cat("Performance Metrics:\n")
  cat("  Average duration:", x$avg_duration, "seconds\n")
  cat("  Median duration:", x$median_duration, "seconds\n")
  cat("  Total duration:", x$total_duration, "seconds\n\n")

  cat("Model Usage:\n")
  cat("  Models used:", x$models_used, "\n")
  cat("  Most used:", x$most_used_model, "\n\n")

  cat("Feature Usage:\n")
  cat("  Features used:", x$features_used, "\n")
  cat("  Most popular:", x$most_used_feature, "\n\n")

  if (x$total_errors > 0) {
    cat("Errors:\n")
    cat("  Total errors:", x$total_errors, "\n")
    cat("  Error rate:", x$error_rate, "%\n\n")
  }

  if (!is.na(x$average_rating)) {
    cat("User Feedback:\n")
    cat("  Average rating:", x$average_rating, "/ 5\n")
    cat("  Total ratings:", x$total_ratings, "\n\n")
  }

  if (!is.null(x$historical)) {
    cat("Historical Data:\n")
    cat("  Total sessions:", x$historical$total_sessions, "\n")
    cat("  Total queries:", x$historical$total_historical_queries, "\n")
  }

  invisible(x)
}

#' Generate Insights
#'
#' Analyze analytics data and generate actionable insights.
#'
#' @return List of insights with recommendations
#' @export
generate_insights <- function() {
  summary <- get_analytics_summary()

  if (is.null(summary$total_queries) || summary$total_queries == 0) {
    return(list(message = "Not enough data for insights"))
  }

  insights <- list()

  # Performance insights
  if (summary$avg_duration > 5) {
    insights$performance_slow <- list(
      type = "warning",
      message = "Average query duration is high (>5s)",
      recommendation = "Consider enabling caching or using faster models",
      metric = paste0("Avg: ", summary$avg_duration, "s")
    )
  }

  # Cache insights
  if (summary$cache_hit_rate < 20 && summary$total_queries > 10) {
    insights$low_cache_usage <- list(
      type = "info",
      message = "Cache hit rate is low",
      recommendation = "Enable caching for repeated queries to improve performance",
      metric = paste0("Hit rate: ", summary$cache_hit_rate, "%")
    )
  } else if (summary$cache_hit_rate > 50) {
    insights$good_cache_usage <- list(
      type = "success",
      message = "Excellent cache utilization",
      recommendation = "Your caching strategy is working well",
      metric = paste0("Hit rate: ", summary$cache_hit_rate, "%")
    )
  }

  # Error rate insights
  if (summary$error_rate > 10) {
    insights$high_error_rate <- list(
      type = "critical",
      message = "High error rate detected",
      recommendation = "Review error logs and check Ollama connection",
      metric = paste0("Error rate: ", summary$error_rate, "%")
    )
  }

  # Model usage insights
  if (summary$models_used == 1 && summary$total_queries > 5) {
    insights$single_model <- list(
      type = "info",
      message = "Only using one model",
      recommendation = "Try comparing multiple models for better results",
      metric = paste0("Models: ", summary$models_used)
    )
  }

  # Feature adoption insights
  if (summary$most_used_feature == "basic_query" && summary$total_queries > 10) {
    insights$basic_usage <- list(
      type = "info",
      message = "Primarily using basic queries",
      recommendation = "Explore advanced features like RAG, online search, or multi-agent workflows",
      metric = "Consider trying: RAG, streaming, multi-agent"
    )
  }

  # Rating insights
  if (!is.na(summary$average_rating)) {
    if (summary$average_rating < 3) {
      insights$low_satisfaction <- list(
        type = "warning",
        message = "User satisfaction is below average",
        recommendation = "Review recent responses and adjust model parameters",
        metric = paste0("Avg rating: ", summary$average_rating, "/5")
      )
    } else if (summary$average_rating >= 4) {
      insights$high_satisfaction <- list(
        type = "success",
        message = "Excellent user satisfaction",
        recommendation = "Continue current configuration",
        metric = paste0("Avg rating: ", summary$average_rating, "/5")
      )
    }
  }

  # Usage pattern insights
  if (summary$total_queries > 50) {
    insights$power_user <- list(
      type = "success",
      message = "You're a power user!",
      recommendation = "Consider exploring automation and workflow features",
      metric = paste0("Total queries: ", summary$total_queries)
    )
  }

  class(insights) <- c("alaquer_insights", "list")
  return(insights)
}

#' Print Insights
#'
#' @param x Insights object
#' @param ... Additional arguments
#' @export
print.alaquer_insights <- function(x, ...) {
  if (length(x) == 0 || !is.null(x$message)) {
    cat("No insights available yet\n")
    return(invisible(x))
  }

  cat("====================================\n")
  cat("ALAQUER Insights & Recommendations\n")
  cat("====================================\n\n")

  for (name in names(x)) {
    insight <- x[[name]]

    icon <- switch(insight$type,
                  "critical" = "[!]",
                  "warning" = "[*]",
                  "info" = "[i]",
                  "success" = "[✓]",
                  "[ ]")

    cat(icon, insight$message, "\n")
    cat("    Recommendation:", insight$recommendation, "\n")
    cat("    Metric:", insight$metric, "\n\n")
  }

  invisible(x)
}

#' Save Analytics
#'
#' Save current analytics data to disk.
#'
#' @param filepath Optional custom filepath (default: uses config path)
#' @return TRUE if successful
#' @export
save_analytics <- function(filepath = NULL) {
  if (!exists("tracking_data", envir = .alaquer_analytics)) {
    warning("No analytics data to save")
    return(FALSE)
  }

  config <- get("config", envir = .alaquer_analytics)
  tracking_data <- get("tracking_data", envir = .alaquer_analytics)

  if (is.null(filepath)) {
    filepath <- file.path(config$storage_path,
                          paste0("analytics_", config$session_id, ".rds"))
  }

  tryCatch({
    saveRDS(tracking_data, filepath)
    assign("last_save_time", Sys.time(), envir = .alaquer_analytics)

    # Update historical data
    if (exists("historical_data", envir = .alaquer_analytics)) {
      historical <- get("historical_data", envir = .alaquer_analytics)
    } else {
      historical <- list()
    }

    # Add summary to historical
    summary <- get_analytics_summary(include_historical = FALSE)
    historical[[config$session_id]] <- summary

    # Save historical
    historical_file <- file.path(config$storage_path, "analytics_history.rds")
    saveRDS(historical, historical_file)

    message("Analytics saved: ", filepath)
    return(TRUE)

  }, error = function(e) {
    warning("Failed to save analytics: ", e$message)
    return(FALSE)
  })
}

#' Load Analytics
#'
#' Load analytics data from a previous session.
#'
#' @param filepath Path to analytics file
#' @return Analytics data
#' @export
load_analytics <- function(filepath) {
  if (!file.exists(filepath)) {
    stop("Analytics file not found: ", filepath)
  }

  tryCatch({
    data <- readRDS(filepath)
    message("Analytics loaded from: ", filepath)
    return(data)
  }, error = function(e) {
    stop("Failed to load analytics: ", e$message)
  })
}

#' Export Analytics Report
#'
#' Export analytics data as HTML or JSON report.
#'
#' @param filepath Output filepath
#' @param format Format ("html" or "json")
#' @return TRUE if successful
#' @export
export_analytics_report <- function(filepath, format = "html") {
  summary <- get_analytics_summary()
  insights <- generate_insights()

  if (format == "json") {
    report <- list(
      generated = Sys.time(),
      summary = summary,
      insights = insights
    )

    tryCatch({
      jsonlite::write_json(report, filepath, pretty = TRUE, auto_unbox = TRUE)
      message("Analytics report exported: ", filepath)
      return(TRUE)
    }, error = function(e) {
      warning("Failed to export report: ", e$message)
      return(FALSE)
    })

  } else if (format == "html") {
    html_content <- generate_html_report(summary, insights)

    tryCatch({
      writeLines(html_content, filepath)
      message("HTML report exported: ", filepath)
      return(TRUE)
    }, error = function(e) {
      warning("Failed to export HTML report: ", e$message)
      return(FALSE)
    })

  } else {
    stop("Invalid format. Must be 'html' or 'json'")
  }
}

#' Generate HTML Report
#'
#' @keywords internal
generate_html_report <- function(summary, insights) {
  html <- paste0('
<!DOCTYPE html>
<html>
<head>
<title>ALAQUER Analytics Report</title>
<style>
body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
.container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
h2 { color: #34495e; margin-top: 30px; }
.metric { display: inline-block; margin: 15px; padding: 20px; background: #ecf0f1; border-radius: 5px; min-width: 150px; }
.metric-value { font-size: 2em; font-weight: bold; color: #3498db; }
.metric-label { font-size: 0.9em; color: #7f8c8d; margin-top: 5px; }
.insight { margin: 15px 0; padding: 15px; border-left: 4px solid #3498db; background: #f8f9fa; }
.insight.warning { border-color: #f39c12; }
.insight.critical { border-color: #e74c3c; }
.insight.success { border-color: #2ecc71; }
.timestamp { color: #95a5a6; font-size: 0.9em; }
</style>
</head>
<body>
<div class="container">
<h1>ALAQUER Analytics Report</h1>
<p class="timestamp">Generated: ', format(Sys.time(), "%Y-%m-%d %H:%M:%S"), '</p>

<h2>Overview</h2>
<div class="metric">
  <div class="metric-value">', summary$total_queries, '</div>
  <div class="metric-label">Total Queries</div>
</div>
<div class="metric">
  <div class="metric-value">', summary$success_rate, '%</div>
  <div class="metric-label">Success Rate</div>
</div>
<div class="metric">
  <div class="metric-value">', summary$cache_hit_rate, '%</div>
  <div class="metric-label">Cache Hit Rate</div>
</div>
<div class="metric">
  <div class="metric-value">', round(summary$session_duration, 1), ' min</div>
  <div class="metric-label">Session Duration</div>
</div>

<h2>Performance</h2>
<div class="metric">
  <div class="metric-value">', summary$avg_duration, 's</div>
  <div class="metric-label">Avg Duration</div>
</div>
<div class="metric">
  <div class="metric-value">', summary$median_duration, 's</div>
  <div class="metric-label">Median Duration</div>
</div>

<h2>Insights & Recommendations</h2>
')

  if (length(insights) > 0 && is.null(insights$message)) {
    for (name in names(insights)) {
      insight <- insights[[name]]
      html <- paste0(html, '
<div class="insight ', insight$type, '">
  <strong>', insight$message, '</strong><br>
  <em>Recommendation:</em> ', insight$recommendation, '<br>
  <span class="timestamp">', insight$metric, '</span>
</div>
')
    }
  } else {
    html <- paste0(html, '<p>No insights available yet.</p>')
  }

  html <- paste0(html, '
</div>
</body>
</html>
')

  return(html)
}

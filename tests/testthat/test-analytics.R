test_that("Analytics initialization works", {
  temp_dir <- tempdir()
  config <- initialize_analytics(storage_path = file.path(temp_dir, "analytics"))

  expect_type(config$session_id, "character")
  expect_true(dir.exists(config$storage_path))
})

test_that("Query tracking works", {
  temp_dir <- tempdir()
  initialize_analytics(storage_path = file.path(temp_dir, "analytics"))

  track_query("test prompt", "llama3.2", 1.5, tokens = 100, cached = FALSE, success = TRUE)
  track_query("test prompt 2", "llama3.2", 0.5, tokens = 50, cached = TRUE, success = TRUE)

  summary <- get_analytics_summary(include_historical = FALSE)

  expect_equal(summary$total_queries, 2)
  expect_equal(summary$cached_queries, 1)
  expect_equal(summary$cache_hit_rate, 50)
})

test_that("Error tracking works", {
  temp_dir <- tempdir()
  initialize_analytics(storage_path = file.path(temp_dir, "analytics"))

  track_error("Test error message", "test_context", "high")

  summary <- get_analytics_summary(include_historical = FALSE)

  expect_equal(summary$total_errors, 1)
})

test_that("User rating tracking works", {
  temp_dir <- tempdir()
  initialize_analytics(storage_path = file.path(temp_dir, "analytics"))

  track_user_rating(5, "Great response", "quality")
  track_user_rating(4, "Good response", "quality")

  summary <- get_analytics_summary(include_historical = FALSE)

  expect_equal(summary$total_ratings, 2)
  expect_equal(summary$average_rating, 4.5)
})

test_that("Insights generation works", {
  temp_dir <- tempdir()
  initialize_analytics(storage_path = file.path(temp_dir, "analytics"))

  # Track multiple queries
  for (i in 1:15) {
    track_query(paste("query", i), "llama3.2", runif(1, 0.5, 2), cached = i %% 2 == 0, success = TRUE)
  }

  insights <- generate_insights()

  expect_type(insights, "list")
  expect_s3_class(insights, "alaquer_insights")
})

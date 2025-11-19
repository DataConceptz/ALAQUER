test_that("Cache system works correctly", {
  # Initialize cache
  config <- create_cache(max_size = 5, ttl = 60)

  expect_equal(config$max_size, 5)
  expect_equal(config$ttl, 60)

  # Generate cache key
  key <- generate_cache_key("test prompt", "llama3.2", 0.7)
  expect_type(key, "character")
  expect_equal(nchar(key), 32)  # MD5 hash length

  # Test cache set and get
  test_response <- list(response = "test response", duration = 1.5)
  set_cached_response(key, test_response)

  cached <- get_cached_response(key)
  expect_equal(cached$response, "test response")

  # Test cache stats
  stats <- get_cache_stats()
  expect_equal(stats$size, 1)
  expect_equal(stats$total_hits, 1)  # One hit from get_cached_response
})

test_that("Memoization works", {
  call_count <- 0

  test_func <- function(x) {
    call_count <<- call_count + 1
    return(x * 2)
  }

  memoized <- memoize(test_func, cache_size = 10)

  result1 <- memoized(5)
  expect_equal(result1, 10)
  expect_equal(call_count, 1)

  # Second call should use cache
  result2 <- memoized(5)
  expect_equal(result2, 10)
  expect_equal(call_count, 1)  # Still 1, not called again

  # Different input should call function
  result3 <- memoized(7)
  expect_equal(result3, 14)
  expect_equal(call_count, 2)
})

test_that("Performance monitoring works", {
  session_id <- start_performance_monitoring()
  expect_type(session_id, "character")

  # Record some metrics
  record_query_metric(session_id, "test_operation", 1.5, cached = FALSE)
  record_query_metric(session_id, "test_operation", 0.5, cached = TRUE)

  # Get report
  report <- get_performance_report(session_id)
  expect_equal(report$total_queries, 2)
  expect_equal(report$cache_hits, 1)
  expect_equal(report$cache_misses, 1)
  expect_equal(report$cache_hit_rate, 50)
})

test_that("Plugin system initialization works", {
  temp_dir <- tempdir()
  config <- initialize_plugin_system(plugin_dirs = file.path(temp_dir, "plugins"), auto_load = FALSE)

  expect_type(config$plugin_dirs, "character")
  expect_false(config$auto_load)
})

test_that("Plugin creation works", {
  test_handler <- function(text) {
    return(toupper(text))
  }

  plugin <- create_plugin(
    name = "test_plugin",
    version = "1.0.0",
    author = "Test Author",
    description = "Test plugin",
    type = "processor",
    handler = test_handler
  )

  expect_s3_class(plugin, "alaquer_plugin")
  expect_equal(plugin$name, "test_plugin")
  expect_equal(plugin$type, "processor")
})

test_that("Plugin registration works", {
  initialize_plugin_system(plugin_dirs = tempdir(), auto_load = FALSE)

  test_handler <- function(text) {
    return(toupper(text))
  }

  plugin <- create_plugin(
    name = "uppercase_plugin",
    version = "1.0.0",
    author = "Test",
    description = "Uppercase processor",
    type = "processor",
    handler = test_handler
  )

  result <- register_plugin(plugin)
  expect_true(result)

  # List plugins
  plugins <- list_plugins()
  expect_true(nrow(plugins) > 0)
  expect_true("uppercase_plugin" %in% plugins$name)
})

test_that("Plugin execution works", {
  initialize_plugin_system(plugin_dirs = tempdir(), auto_load = FALSE)

  test_handler <- function(text) {
    return(toupper(text))
  }

  plugin <- create_plugin(
    name = "uppercase_plugin",
    version = "1.0.0",
    author = "Test",
    description = "Uppercase processor",
    type = "processor",
    handler = test_handler
  )

  register_plugin(plugin)

  result <- execute_plugin("uppercase_plugin", "processor", text = "hello world")
  expect_equal(result, "HELLO WORLD")
})

test_that("Plugin enable/disable works", {
  initialize_plugin_system(plugin_dirs = tempdir(), auto_load = FALSE)

  test_handler <- function(x) { return(x * 2) }

  plugin <- create_plugin(
    name = "double_plugin",
    version = "1.0.0",
    author = "Test",
    description = "Double processor",
    type = "processor",
    handler = test_handler
  )

  register_plugin(plugin)

  # Test enabled
  result <- execute_plugin("double_plugin", "processor", x = 5)
  expect_equal(result, 10)

  # Disable
  set_plugin_enabled("double_plugin", "processor", FALSE)

  # Should return NULL when disabled
  result <- execute_plugin("double_plugin", "processor", x = 5)
  expect_null(result)
})

#' Plugin Architecture System
#'
#' Extensible plugin system allowing users to add custom functionality,
#' custom models, custom processors, and custom UI components.
#'
#' @name plugins
NULL

# Plugin registry environment
.alaquer_plugins <- new.env(parent = emptyenv())

#' Initialize Plugin System
#'
#' Set up the plugin system with plugin discovery and loading.
#'
#' @param plugin_dirs Vector of directories to search for plugins (default: "~/.alaquer/plugins")
#' @param auto_load Whether to automatically load discovered plugins (default: FALSE)
#' @return Plugin system configuration
#' @export
initialize_plugin_system <- function(plugin_dirs = "~/.alaquer/plugins", auto_load = FALSE) {
  plugin_dirs <- path.expand(plugin_dirs)

  # Create plugin directories if they don't exist
  for (dir in plugin_dirs) {
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = TRUE)
      message("Created plugin directory: ", dir)
    }
  }

  config <- list(
    plugin_dirs = plugin_dirs,
    auto_load = auto_load,
    initialized = Sys.time()
  )

  # Initialize plugin registry
  registry <- list(
    processors = list(),
    models = list(),
    ui_components = list(),
    hooks = list(),
    commands = list()
  )

  assign("config", config, envir = .alaquer_plugins)
  assign("registry", registry, envir = .alaquer_plugins)

  # Discover plugins
  discovered <- discover_plugins(plugin_dirs)
  assign("discovered", discovered, envir = .alaquer_plugins)

  message("Plugin system initialized")
  message("Discovered ", length(discovered), " plugins")

  if (auto_load) {
    load_all_plugins()
  }

  invisible(config)
}

#' Create Plugin
#'
#' Create a new plugin with metadata and functionality.
#'
#' @param name Plugin name
#' @param version Plugin version
#' @param author Plugin author
#' @param description Plugin description
#' @param type Plugin type ("processor", "model", "ui", "hook", "command")
#' @param handler Main plugin function
#' @param dependencies Plugin dependencies (optional)
#' @return Plugin object
#' @export
create_plugin <- function(name, version, author, description, type, handler, dependencies = NULL) {
  if (!type %in% c("processor", "model", "ui", "hook", "command")) {
    stop("Invalid plugin type. Must be: processor, model, ui, hook, or command")
  }

  if (!is.function(handler)) {
    stop("Handler must be a function")
  }

  plugin <- list(
    name = name,
    version = version,
    author = author,
    description = description,
    type = type,
    handler = handler,
    dependencies = dependencies,
    created = Sys.time(),
    loaded = FALSE,
    enabled = TRUE
  )

  class(plugin) <- c("alaquer_plugin", "list")
  return(plugin)
}

#' Register Plugin
#'
#' Register a plugin with the ALAQUER plugin system.
#'
#' @param plugin Plugin object
#' @return TRUE if successful
#' @export
register_plugin <- function(plugin) {
  if (!exists("registry", envir = .alaquer_plugins)) {
    initialize_plugin_system()
  }

  registry <- get("registry", envir = .alaquer_plugins)

  # Check dependencies
  if (!is.null(plugin$dependencies)) {
    for (dep in plugin$dependencies) {
      if (!requireNamespace(dep, quietly = TRUE)) {
        warning("Plugin '", plugin$name, "' requires package: ", dep)
        return(FALSE)
      }
    }
  }

  # Register based on type
  type_key <- switch(plugin$type,
                    "processor" = "processors",
                    "model" = "models",
                    "ui" = "ui_components",
                    "hook" = "hooks",
                    "command" = "commands")

  if (plugin$name %in% names(registry[[type_key]])) {
    warning("Plugin '", plugin$name, "' is already registered. Overwriting.")
  }

  registry[[type_key]][[plugin$name]] <- plugin
  plugin$loaded <- TRUE

  assign("registry", registry, envir = .alaquer_plugins)

  message("Registered plugin: ", plugin$name, " (", plugin$type, ")")
  invisible(TRUE)
}

#' Unregister Plugin
#'
#' Remove a plugin from the registry.
#'
#' @param plugin_name Plugin name
#' @param type Plugin type
#' @export
unregister_plugin <- function(plugin_name, type) {
  if (!exists("registry", envir = .alaquer_plugins)) {
    warning("Plugin system not initialized")
    return(FALSE)
  }

  registry <- get("registry", envir = .alaquer_plugins)

  type_key <- switch(type,
                    "processor" = "processors",
                    "model" = "models",
                    "ui" = "ui_components",
                    "hook" = "hooks",
                    "command" = "commands")

  if (plugin_name %in% names(registry[[type_key]])) {
    registry[[type_key]][[plugin_name]] <- NULL
    assign("registry", registry, envir = .alaquer_plugins)
    message("Unregistered plugin: ", plugin_name)
    return(TRUE)
  } else {
    warning("Plugin not found: ", plugin_name)
    return(FALSE)
  }
}

#' Execute Plugin
#'
#' Execute a registered plugin with provided arguments.
#'
#' @param plugin_name Plugin name
#' @param type Plugin type
#' @param ... Arguments to pass to plugin handler
#' @return Plugin execution result
#' @export
execute_plugin <- function(plugin_name, type, ...) {
  if (!exists("registry", envir = .alaquer_plugins)) {
    stop("Plugin system not initialized")
  }

  registry <- get("registry", envir = .alaquer_plugins)

  type_key <- switch(type,
                    "processor" = "processors",
                    "model" = "models",
                    "ui" = "ui_components",
                    "hook" = "hooks",
                    "command" = "commands")

  if (!plugin_name %in% names(registry[[type_key]])) {
    stop("Plugin not found: ", plugin_name)
  }

  plugin <- registry[[type_key]][[plugin_name]]

  if (!plugin$enabled) {
    warning("Plugin is disabled: ", plugin_name)
    return(NULL)
  }

  tryCatch({
    result <- plugin$handler(...)
    return(result)
  }, error = function(e) {
    warning("Plugin execution failed: ", plugin_name, " - ", e$message)
    return(NULL)
  })
}

#' List Plugins
#'
#' List all registered plugins.
#'
#' @param type Optional plugin type filter
#' @return Data frame of plugins
#' @export
list_plugins <- function(type = NULL) {
  if (!exists("registry", envir = .alaquer_plugins)) {
    return(data.frame())
  }

  registry <- get("registry", envir = .alaquer_plugins)

  all_plugins <- list()

  for (type_name in names(registry)) {
    for (plugin_name in names(registry[[type_name]])) {
      plugin <- registry[[type_name]][[plugin_name]]
      all_plugins[[length(all_plugins) + 1]] <- data.frame(
        name = plugin$name,
        type = plugin$type,
        version = plugin$version,
        author = plugin$author,
        description = plugin$description,
        enabled = plugin$enabled,
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(all_plugins) == 0) {
    return(data.frame())
  }

  df <- do.call(rbind, all_plugins)

  if (!is.null(type)) {
    df <- df[df$type == type, ]
  }

  return(df)
}

#' Discover Plugins
#'
#' Scan plugin directories for available plugins.
#'
#' @param plugin_dirs Vector of directories to search
#' @return List of discovered plugin paths
#' @export
discover_plugins <- function(plugin_dirs) {
  discovered <- list()

  for (dir in plugin_dirs) {
    if (!dir.exists(dir)) {
      next
    }

    # Look for R files in plugin directory
    plugin_files <- list.files(dir, pattern = "\\.R$", full.names = TRUE, recursive = TRUE)

    for (file in plugin_files) {
      # Check if file contains plugin definition
      tryCatch({
        # Read file
        content <- readLines(file, warn = FALSE)

        # Look for ALAQUER_PLUGIN marker
        if (any(grepl("#' @ALAQUER_PLUGIN", content, fixed = TRUE))) {
          discovered[[basename(file)]] <- file
          message("Discovered plugin: ", file)
        }
      }, error = function(e) {
        # Skip files that can't be read
      })
    }
  }

  return(discovered)
}

#' Load Plugin from File
#'
#' Load and register a plugin from an R file.
#'
#' @param filepath Path to plugin file
#' @return TRUE if successful
#' @export
load_plugin <- function(filepath) {
  if (!file.exists(filepath)) {
    warning("Plugin file not found: ", filepath)
    return(FALSE)
  }

  tryCatch({
    # Source the plugin file
    source(filepath, local = TRUE)

    message("Loaded plugin from: ", filepath)
    return(TRUE)

  }, error = function(e) {
    warning("Failed to load plugin: ", filepath, " - ", e$message)
    return(FALSE)
  })
}

#' Load All Plugins
#'
#' Load all discovered plugins.
#'
#' @return Number of plugins loaded
#' @export
load_all_plugins <- function() {
  if (!exists("discovered", envir = .alaquer_plugins)) {
    warning("No plugins discovered. Run discover_plugins() first.")
    return(0)
  }

  discovered <- get("discovered", envir = .alaquer_plugins)

  if (length(discovered) == 0) {
    message("No plugins to load")
    return(0)
  }

  loaded_count <- 0

  for (plugin_path in discovered) {
    if (load_plugin(plugin_path)) {
      loaded_count <- loaded_count + 1
    }
  }

  message("Loaded ", loaded_count, " plugins")
  return(loaded_count)
}

#' Enable/Disable Plugin
#'
#' Enable or disable a registered plugin.
#'
#' @param plugin_name Plugin name
#' @param type Plugin type
#' @param enabled TRUE to enable, FALSE to disable
#' @export
set_plugin_enabled <- function(plugin_name, type, enabled = TRUE) {
  if (!exists("registry", envir = .alaquer_plugins)) {
    stop("Plugin system not initialized")
  }

  registry <- get("registry", envir = .alaquer_plugins)

  type_key <- switch(type,
                    "processor" = "processors",
                    "model" = "models",
                    "ui" = "ui_components",
                    "hook" = "hooks",
                    "command" = "commands")

  if (!plugin_name %in% names(registry[[type_key]])) {
    stop("Plugin not found: ", plugin_name)
  }

  registry[[type_key]][[plugin_name]]$enabled <- enabled
  assign("registry", registry, envir = .alaquer_plugins)

  message("Plugin '", plugin_name, "' ", if (enabled) "enabled" else "disabled")
  invisible(NULL)
}

#' Create Plugin Template
#'
#' Generate a template file for creating a new plugin.
#'
#' @param plugin_name Plugin name
#' @param type Plugin type
#' @param output_path Output file path
#' @export
create_plugin_template <- function(plugin_name, type, output_path) {
  template <- paste0('
#\' @ALAQUER_PLUGIN
#\' Plugin: ', plugin_name, '
#\' Type: ', type, '
#\' Version: 1.0.0
#\' Author: Your Name
#\' Description: Description of what this plugin does

# Plugin handler function
', plugin_name, '_handler <- function(...) {
  args <- list(...)

  # Your plugin logic here
  message("', plugin_name, ' plugin executed")

  # Return result
  return(list(
    success = TRUE,
    result = "Plugin result"
  ))
}

# Create and register the plugin
plugin <- create_plugin(
  name = "', plugin_name, '",
  version = "1.0.0",
  author = "Your Name",
  description = "Description of what this plugin does",
  type = "', type, '",
  handler = ', plugin_name, '_handler,
  dependencies = NULL  # Add package dependencies here
)

# Register the plugin
register_plugin(plugin)

message("Plugin \'', plugin_name, '\' loaded successfully")
')

  tryCatch({
    writeLines(template, output_path)
    message("Plugin template created: ", output_path)
    message("Edit the file and load it with load_plugin('", output_path, "')")
    return(TRUE)
  }, error = function(e) {
    warning("Failed to create plugin template: ", e$message)
    return(FALSE)
  })
}

#' Execute Hook Plugins
#'
#' Execute all registered hook plugins for a specific event.
#'
#' @param hook_name Hook event name
#' @param data Data to pass to hook handlers
#' @return Modified data after all hooks execute
#' @export
execute_hooks <- function(hook_name, data) {
  if (!exists("registry", envir = .alaquer_plugins)) {
    return(data)
  }

  registry <- get("registry", envir = .alaquer_plugins)
  hooks <- registry$hooks

  if (length(hooks) == 0) {
    return(data)
  }

  # Execute all hooks that match this event
  for (plugin_name in names(hooks)) {
    plugin <- hooks[[plugin_name]]

    if (!plugin$enabled) {
      next
    }

    # Check if this hook handles this event
    tryCatch({
      result <- plugin$handler(hook_name = hook_name, data = data)

      # Allow hooks to modify data
      if (!is.null(result)) {
        data <- result
      }
    }, error = function(e) {
      warning("Hook plugin failed: ", plugin_name, " - ", e$message)
    })
  }

  return(data)
}

#' Example: Sentiment Analysis Plugin
#'
#' Example processor plugin that performs sentiment analysis on text.
#'
#' @param text Text to analyze
#' @return Sentiment analysis result
#' @export
example_sentiment_plugin <- function() {
  sentiment_handler <- function(text) {
    # Simple sentiment analysis based on keyword matching
    positive_words <- c("good", "great", "excellent", "amazing", "wonderful", "fantastic", "happy", "love")
    negative_words <- c("bad", "terrible", "awful", "horrible", "sad", "hate", "poor", "worst")

    text_lower <- tolower(text)

    positive_count <- sum(sapply(positive_words, function(w) grepl(w, text_lower, fixed = TRUE)))
    negative_count <- sum(sapply(negative_words, function(w) grepl(w, text_lower, fixed = TRUE)))

    score <- positive_count - negative_count

    sentiment <- if (score > 0) {
      "positive"
    } else if (score < 0) {
      "negative"
    } else {
      "neutral"
    }

    return(list(
      sentiment = sentiment,
      score = score,
      positive_count = positive_count,
      negative_count = negative_count
    ))
  }

  plugin <- create_plugin(
    name = "sentiment_analyzer",
    version = "1.0.0",
    author = "ALAQUER Team",
    description = "Performs sentiment analysis on text responses",
    type = "processor",
    handler = sentiment_handler
  )

  register_plugin(plugin)
  message("Example sentiment analysis plugin registered")
  message("Usage: execute_plugin('sentiment_analyzer', 'processor', text = 'Your text here')")

  invisible(plugin)
}

#' Example: Response Filter Plugin
#'
#' Example hook plugin that filters/modifies responses.
#'
#' @export
example_filter_plugin <- function() {
  filter_handler <- function(hook_name, data) {
    if (hook_name == "response_received") {
      # Example: Add timestamp to response
      if (is.character(data)) {
        data <- paste0("[", format(Sys.time(), "%H:%M:%S"), "] ", data)
      }
    }

    return(data)
  }

  plugin <- create_plugin(
    name = "response_filter",
    version = "1.0.0",
    author = "ALAQUER Team",
    description = "Filters and modifies responses with timestamps",
    type = "hook",
    handler = filter_handler
  )

  register_plugin(plugin)
  message("Example response filter plugin registered")
  message("This hook will add timestamps to responses")

  invisible(plugin)
}

#' Get Plugin Info
#'
#' Get detailed information about a plugin.
#'
#' @param plugin_name Plugin name
#' @param type Plugin type
#' @return Plugin information list
#' @export
get_plugin_info <- function(plugin_name, type) {
  if (!exists("registry", envir = .alaquer_plugins)) {
    stop("Plugin system not initialized")
  }

  registry <- get("registry", envir = .alaquer_plugins)

  type_key <- switch(type,
                    "processor" = "processors",
                    "model" = "models",
                    "ui" = "ui_components",
                    "hook" = "hooks",
                    "command" = "commands")

  if (!plugin_name %in% names(registry[[type_key]])) {
    stop("Plugin not found: ", plugin_name)
  }

  plugin <- registry[[type_key]][[plugin_name]]

  info <- list(
    name = plugin$name,
    type = plugin$type,
    version = plugin$version,
    author = plugin$author,
    description = plugin$description,
    enabled = plugin$enabled,
    loaded = plugin$loaded,
    created = plugin$created,
    dependencies = plugin$dependencies
  )

  class(info) <- c("alaquer_plugin_info", "list")
  return(info)
}

#' Print Plugin Info
#'
#' @param x Plugin info object
#' @param ... Additional arguments
#' @export
print.alaquer_plugin_info <- function(x, ...) {
  cat("Plugin:", x$name, "\n")
  cat("Type:", x$type, "\n")
  cat("Version:", x$version, "\n")
  cat("Author:", x$author, "\n")
  cat("Description:", x$description, "\n")
  cat("Status:", if (x$enabled) "Enabled" else "Disabled", "\n")

  if (!is.null(x$dependencies) && length(x$dependencies) > 0) {
    cat("Dependencies:", paste(x$dependencies, collapse = ", "), "\n")
  }

  invisible(x)
}

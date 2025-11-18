#' Create ALAQUER Server
#'
#' Build the main server logic for ALAQUER
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param ollama_host Character string. Default Ollama host
#' @return Server function
create_alaquer_server <- function(input, output, session, ollama_host = "http://localhost:11434") {

  # Reactive values for storing state
  rv <- shiny::reactiveValues(
    chat_history = list(),
    last_query = "",
    last_response = "",
    knowledge_base = NULL,
    models_list = character(),
    is_processing = FALSE,
    connection_ok = FALSE,
    example_prompts = NULL
  )

  # Initialize on startup
  shiny::observe({
    # Check Ollama connection
    rv$connection_ok <- check_ollama_connection(input$ollama_host)

    # Load models
    if (rv$connection_ok) {
      models <- get_ollama_models(input$ollama_host)
      if (!is.null(models) && length(models) > 0) {
        rv$models_list <- models
        shiny::updateSelectInput(session, "selected_model",
                                choices = models,
                                selected = models[1])
      }
    }

    # Load example prompts
    rv$example_prompts <- get_example_prompts()

    # Update prompt categories
    categories <- names(rv$example_prompts)
    category_names <- sapply(rv$example_prompts, function(x) x$name)
    names(category_names) <- categories

    shiny::updateSelectInput(session, "prompt_category",
                            choices = category_names)
  })

  # Connection Status Display
  output$connection_status <- shiny::renderUI({
    if (rv$connection_ok) {
      tags$div(
        style = "padding: 10px; background-color: #d1fae5; border-radius: 6px; margin-top: 10px;",
        tags$span(class = "status-connected", shiny::icon("check-circle")),
        tags$span(" Connected", style = "color: #065f46; margin-left: 8px;")
      )
    } else {
      tags$div(
        style = "padding: 10px; background-color: #fee2e2; border-radius: 6px; margin-top: 10px;",
        tags$span(class = "status-disconnected", shiny::icon("times-circle")),
        tags$span(" Disconnected", style = "color: #991b1b; margin-left: 8px;")
      )
    }
  })

  # Refresh Models Button
  shiny::observeEvent(input$refresh_models, {
    rv$connection_ok <- check_ollama_connection(input$ollama_host)

    if (rv$connection_ok) {
      models <- get_ollama_models(input$ollama_host)
      if (!is.null(models) && length(models) > 0) {
        rv$models_list <- models
        shiny::updateSelectInput(session, "selected_model",
                                choices = models,
                                selected = models[1])
        shiny::showNotification("Models refreshed successfully!", type = "message")
      } else {
        shiny::showNotification("No models found. Please pull a model using 'ollama pull <model>'",
                              type = "warning")
      }
    } else {
      shiny::showNotification("Cannot connect to Ollama. Please check if Ollama is running.",
                            type = "error")
    }
  })

  # Update example prompts when category changes
  shiny::observeEvent(input$prompt_category, {
    if (!is.null(input$prompt_category) && input$prompt_category != "") {
      category_prompts <- rv$example_prompts[[input$prompt_category]]$prompts

      # Create named vector for dropdown
      prompt_choices <- setNames(category_prompts,
                                paste0(seq_along(category_prompts), ". ",
                                      truncate_text(category_prompts, 60)))

      shiny::updateSelectInput(session, "example_prompt",
                              choices = c("Select a prompt..." = "", prompt_choices))
    }
  })

  # Use Example Prompt Button
  shiny::observeEvent(input$use_example, {
    if (!is.null(input$example_prompt) && input$example_prompt != "") {
      shiny::updateTextAreaInput(session, "query_input", value = input$example_prompt)
      shiny::showNotification("Prompt loaded! You can edit it before sending.", type = "message")
    }
  })

  # Enhance Prompt Button
  shiny::observeEvent(input$enhance_prompt, {
    if (nchar(input$query_input) == 0) {
      shiny::showNotification("Please enter some text to enhance", type = "warning")
      return()
    }

    if (!rv$connection_ok || is.null(input$selected_model) || input$selected_model == "") {
      shiny::showNotification("Please select a model first", type = "warning")
      return()
    }

    shiny::showNotification("Enhancing prompt...", type = "message", duration = 2)

    enhanced <- enhance_prompt(
      input = input$query_input,
      length = input$prompt_length,
      model = input$selected_model,
      host = input$ollama_host
    )

    shiny::updateTextAreaInput(session, "query_input", value = enhanced)
    shiny::showNotification("Prompt enhanced successfully!", type = "message")
  })

  # Process Knowledge Base
  shiny::observeEvent(input$process_kb, {
    if (is.null(input$kb_files)) {
      shiny::showNotification("Please select files to process", type = "warning")
      return()
    }

    shiny::showNotification("Processing documents...", type = "message", duration = NULL, id = "kb_processing")

    tryCatch({
      file_paths <- input$kb_files$datapath

      rv$knowledge_base <- create_knowledge_base(
        file_paths = file_paths,
        kb_name = "user_kb",
        chunk_size = input$chunk_size,
        overlap = input$chunk_overlap
      )

      shiny::removeNotification("kb_processing")

      if (!is.null(rv$knowledge_base)) {
        shiny::showNotification(
          paste("Successfully processed",
                rv$knowledge_base$metadata$total_documents,
                "documents with",
                rv$knowledge_base$metadata$total_chunks,
                "chunks"),
          type = "message"
        )
      } else {
        shiny::showNotification("Failed to process documents", type = "error")
      }

    }, error = function(e) {
      shiny::removeNotification("kb_processing")
      shiny::showNotification(paste("Error processing documents:", e$message), type = "error")
    })
  })

  # Knowledge Base Status Display
  output$kb_status <- shiny::renderUI({
    if (is.null(rv$knowledge_base)) {
      tags$div(
        style = "padding: 15px; background-color: #f3f4f6; border-radius: 6px;",
        tags$p("No knowledge base loaded", style = "margin: 0; color: #6b7280;")
      )
    } else {
      kb <- rv$knowledge_base
      tags$div(
        style = "padding: 15px; background-color: #d1fae5; border-radius: 6px;",
        tags$p(
          tags$strong("Documents: "), kb$metadata$total_documents, tags$br(),
          tags$strong("Chunks: "), kb$metadata$total_chunks, tags$br(),
          tags$strong("Avg Chunk Size: "), round(kb$metadata$avg_chunk_size), " chars",
          style = "margin: 0; color: #065f46;"
        )
      )
    }
  })

  # Knowledge Base Documents Table
  output$kb_documents_table <- DT::renderDataTable({
    if (is.null(rv$knowledge_base)) {
      return(data.frame(Message = "No documents loaded"))
    }

    docs <- rv$knowledge_base$documents
    doc_data <- do.call(rbind, lapply(names(docs), function(id) {
      doc <- docs[[id]]
      data.frame(
        Name = doc$name,
        Type = doc$doc_type,
        Chunks = doc$chunk_count,
        Keywords = paste(head(doc$keywords, 5), collapse = ", "),
        stringsAsFactors = FALSE
      )
    }))

    DT::datatable(doc_data,
                 options = list(pageLength = 10, scrollX = TRUE),
                 rownames = FALSE)
  })

  # Clear Knowledge Base
  shiny::observeEvent(input$clear_kb, {
    rv$knowledge_base <- NULL
    shiny::updateCheckboxInput(session, "use_knowledge_base", value = FALSE)
    shiny::showNotification("Knowledge base cleared", type = "message")
  })

  # Send Query Button
  shiny::observeEvent(input$send_query, {
    send_query_handler()
  })

  # Enter key press (JavaScript binding would be set in UI)
  send_query_handler <- function() {
    query <- trimws(input$query_input)

    if (nchar(query) == 0) {
      shiny::showNotification("Please enter a query", type = "warning")
      return()
    }

    if (!rv$connection_ok) {
      shiny::showNotification("Not connected to Ollama", type = "error")
      return()
    }

    if (is.null(input$selected_model) || input$selected_model == "") {
      shiny::showNotification("Please select a model", type = "warning")
      return()
    }

    rv$is_processing <- TRUE
    rv$last_query <- query

    # Add user message to chat
    rv$chat_history[[length(rv$chat_history) + 1]] <- list(
      type = "user",
      content = query,
      timestamp = Sys.time()
    )

    # Clear input
    shiny::updateTextAreaInput(session, "query_input", value = "")

    # Build enhanced prompt
    enhanced_query <- query

    # Add online search context if enabled
    if (input$use_online_search && length(input$search_sources) > 0) {
      shiny::showNotification("Searching online...", type = "message", duration = 2)

      search_results <- search_online(
        query = query,
        sources = input$search_sources,
        max_results = input$max_search_results
      )

      if (nrow(search_results) > 0) {
        search_context <- format_search_context(search_results, max_results = input$max_search_results)
        enhanced_query <- paste0(search_context, "\n\nUser query: ", query)
      }
    }

    # Add knowledge base context if enabled
    if (input$use_knowledge_base && !is.null(rv$knowledge_base)) {
      kb_context <- get_kb_context(
        rv$knowledge_base,
        query,
        max_context = input$kb_max_results
      )

      if (nchar(kb_context) > 0) {
        enhanced_query <- paste0(kb_context, "\n\n", enhanced_query)
      }
    }

    # Query Ollama
    shiny::showNotification("Processing query...", type = "message", duration = NULL, id = "processing")

    tryCatch({
      result <- ollama_query(
        prompt = enhanced_query,
        model = input$selected_model,
        host = input$ollama_host,
        temperature = input$temperature,
        top_p = input$top_p,
        max_tokens = input$max_tokens
      )

      shiny::removeNotification("processing")

      if (!is.null(result) && !is.null(result$text)) {
        # Process response
        processed_response <- process_response(
          text = result$text,
          options = list(
            format_code = input$format_code,
            highlight_terms = input$highlight_terms,
            structure_text = input$structure_text,
            optimize_length = input$response_length
          )
        )

        rv$last_response <- processed_response

        # Add AI response to chat
        rv$chat_history[[length(rv$chat_history) + 1]] <- list(
          type = "ai",
          content = processed_response,
          timestamp = Sys.time(),
          model = result$model
        )

        shiny::showNotification("Response received!", type = "message")

      } else {
        shiny::showNotification("Failed to get response from AI", type = "error")
      }

    }, error = function(e) {
      shiny::removeNotification("processing")
      shiny::showNotification(paste("Error:", e$message), type = "error")
    })

    rv$is_processing <- FALSE
  }

  # Chat Display
  output$chat_display <- shiny::renderUI({
    if (length(rv$chat_history) == 0) {
      return(tags$div(
        style = "text-align: center; padding: 60px 20px; color: #9ca3af;",
        tags$div(
          shiny::icon("comments", "fa-3x"),
          style = "margin-bottom: 20px;"
        ),
        tags$h3("Welcome to ALAQUER!", style = "color: #6b7280;"),
        tags$p("Start a conversation by typing a message below."),
        tags$p("Use the features in the sidebar to customize your experience.")
      ))
    }

    # Render chat messages
    chat_elements <- lapply(rv$chat_history, function(msg) {
      if (msg$type == "user") {
        tags$div(
          class = "chat-message user-message",
          tags$div(
            class = "message-label user-label",
            shiny::icon("user"),
            " You"
          ),
          tags$div(
            class = "message-content",
            msg$content
          ),
          tags$div(
            class = "message-timestamp",
            format(msg$timestamp, "%I:%M %p")
          )
        )
      } else {
        tags$div(
          class = "chat-message ai-message",
          tags$div(
            class = "message-label ai-label",
            shiny::icon("robot"),
            " AI Assistant",
            if (!is.null(msg$model)) {
              tags$span(
                paste0(" (", msg$model, ")"),
                style = "font-weight: normal; font-size: 12px;"
              )
            }
          ),
          tags$div(
            class = "message-content",
            shiny::HTML(markdown::markdownToHTML(text = msg$content, fragment.only = TRUE))
          ),
          tags$div(
            class = "message-timestamp",
            format(msg$timestamp, "%I:%M %p")
          )
        )
      }
    })

    tags$div(id = "chat_display", chat_elements)
  })

  # Clear Chat Button
  shiny::observeEvent(input$clear_chat, {
    rv$chat_history <- list()
    rv$last_query <- ""
    rv$last_response <- ""
    shiny::showNotification("Chat cleared", type = "message")
  })

  # Copy Last Response Button
  shiny::observeEvent(input$copy_response, {
    if (nchar(rv$last_response) == 0) {
      shiny::showNotification("No response to copy", type = "warning")
      return()
    }

    tryCatch({
      clipr::write_clip(rv$last_response)
      shiny::showNotification("Response copied to clipboard!", type = "message")
    }, error = function(e) {
      shiny::showNotification("Failed to copy to clipboard", type = "error")
    })
  })

  # Re-ask Last Query Button
  shiny::observeEvent(input$reaskg_query, {
    if (nchar(rv$last_query) == 0) {
      shiny::showNotification("No previous query to repeat", type = "warning")
      return()
    }

    shiny::updateTextAreaInput(session, "query_input", value = rv$last_query)
    shiny::showNotification("Previous query loaded", type = "message")
  })

  # Stop Query Button
  shiny::observeEvent(input$stop_query, {
    rv$is_processing <- FALSE
    shiny::removeNotification("processing")
    shiny::showNotification("Query stopped", type = "message")
  })

  # Export Chat
  shiny::observeEvent(input$export_chat, {
    if (length(rv$chat_history) == 0) {
      shiny::showNotification("No chat history to export", type = "warning")
      return()
    }

    shiny::showNotification("Chat ready for download", type = "message")
  })

  # Download Chat Handler
  output$download_chat <- shiny::downloadHandler(
    filename = function() {
      paste0("alaquer_chat_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".md")
    },
    content = function(file) {
      if (length(rv$chat_history) == 0) {
        return()
      }

      # Create markdown content
      md_content <- c(
        "# ALAQUER Chat Export",
        paste("**Date:**", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
        paste("**Model:**", input$selected_model),
        "",
        "---",
        ""
      )

      for (msg in rv$chat_history) {
        if (msg$type == "user") {
          md_content <- c(
            md_content,
            paste("## User -", format(msg$timestamp, "%I:%M %p")),
            "",
            msg$content,
            ""
          )
        } else {
          md_content <- c(
            md_content,
            paste("## AI Assistant -", format(msg$timestamp, "%I:%M %p")),
            "",
            msg$content,
            ""
          )
        }
      }

      writeLines(md_content, file)
    }
  )

  # System Requirements Display
  output$system_requirements <- shiny::renderPrint({
    reqs <- check_system_requirements()

    cat("=== R Version ===\n")
    cat("Required:", reqs$r_version$required, "\n")
    cat("Installed:", reqs$r_version$installed, "\n")
    cat("Status:", ifelse(reqs$r_version$met, "OK", "UPGRADE NEEDED"), "\n\n")

    cat("=== Packages ===\n")
    for (pkg in names(reqs$packages)) {
      pkg_info <- reqs$packages[[pkg]]
      status <- ifelse(pkg_info$installed, "OK", "MISSING")
      version <- ifelse(pkg_info$installed, pkg_info$version, "Not installed")
      cat(sprintf("%-20s: %-10s [%s]\n", pkg, status, version))
    }

    cat("\n=== Ollama ===\n")
    cat("Status:", ifelse(reqs$ollama$available, "Connected", "Not connected"), "\n")

    cat("\n=== Overall Status ===\n")
    cat(toupper(reqs$status), "\n")
  })

  return(rv)
}

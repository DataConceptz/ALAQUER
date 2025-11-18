#' Create ALAQUER UI
#'
#' Build the main user interface for ALAQUER
#'
#' @param ollama_host Character string. Default Ollama host
#' @return Shiny UI object
#' @importFrom shiny fluidPage tags textInput actionButton uiOutput
#' @importFrom shinydashboard dashboardPage dashboardHeader dashboardSidebar dashboardBody box
create_alaquer_ui <- function(ollama_host = "http://localhost:11434") {

  # Custom CSS for ChatGPT-style interface
  custom_css <- tags$head(
    tags$style(HTML("
      /* Main styling */
      body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        background-color: #f7f7f8;
      }

      /* Chat area styling */
      #chat_display {
        background-color: white;
        border-radius: 8px;
        padding: 20px;
        min-height: 500px;
        max-height: 600px;
        overflow-y: auto;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      }

      .chat-message {
        margin-bottom: 20px;
        animation: fadeIn 0.3s;
      }

      @keyframes fadeIn {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
      }

      .user-message {
        background-color: #f7f7f8;
        border-left: 4px solid #10a37f;
        padding: 12px 16px;
        border-radius: 8px;
        margin-bottom: 8px;
      }

      .ai-message {
        background-color: white;
        border-left: 4px solid #7c3aed;
        padding: 12px 16px;
        border-radius: 8px;
        margin-bottom: 8px;
      }

      .message-label {
        font-weight: 600;
        font-size: 14px;
        color: #374151;
        margin-bottom: 6px;
      }

      .user-label {
        color: #10a37f;
      }

      .ai-label {
        color: #7c3aed;
      }

      .message-content {
        color: #374151;
        line-height: 1.6;
        word-wrap: break-word;
      }

      .message-timestamp {
        font-size: 11px;
        color: #9ca3af;
        margin-top: 6px;
      }

      /* Input area styling */
      #query_input_container {
        background-color: white;
        border-radius: 8px;
        padding: 16px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        margin-top: 16px;
      }

      #query_input {
        border: 1px solid #d1d5db;
        border-radius: 6px;
        padding: 12px;
        font-size: 14px;
        width: 100%;
        min-height: 60px;
        resize: vertical;
      }

      #query_input:focus {
        outline: none;
        border-color: #10a37f;
        box-shadow: 0 0 0 3px rgba(16, 163, 127, 0.1);
      }

      /* Button styling */
      .btn-primary {
        background-color: #10a37f;
        border-color: #10a37f;
        color: white;
        font-weight: 500;
        border-radius: 6px;
        padding: 10px 20px;
        transition: background-color 0.2s;
      }

      .btn-primary:hover {
        background-color: #0d8c6b;
        border-color: #0d8c6b;
      }

      .btn-secondary {
        background-color: #6b7280;
        border-color: #6b7280;
        color: white;
        border-radius: 6px;
        padding: 8px 16px;
      }

      .btn-secondary:hover {
        background-color: #4b5563;
        border-color: #4b5563;
      }

      .btn-danger {
        background-color: #ef4444;
        border-color: #ef4444;
        border-radius: 6px;
      }

      .btn-danger:hover {
        background-color: #dc2626;
        border-color: #dc2626;
      }

      /* Sidebar styling */
      .sidebar {
        background-color: #1f2937;
      }

      .sidebar-menu > li > a {
        color: #e5e7eb;
      }

      /* Box styling */
      .box {
        border-radius: 8px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      }

      .box-header {
        background-color: #f9fafb;
        border-radius: 8px 8px 0 0;
      }

      /* Status indicators */
      .status-connected {
        color: #10b981;
        font-weight: 600;
      }

      .status-disconnected {
        color: #ef4444;
        font-weight: 600;
      }

      /* Code blocks */
      pre {
        background-color: #f3f4f6;
        border: 1px solid #e5e7eb;
        border-radius: 6px;
        padding: 12px;
        overflow-x: auto;
      }

      code {
        background-color: #f3f4f6;
        padding: 2px 6px;
        border-radius: 3px;
        font-family: 'Courier New', monospace;
        font-size: 13px;
      }

      /* Loading spinner */
      .spinner {
        border: 3px solid #f3f4f6;
        border-top: 3px solid #10a37f;
        border-radius: 50%;
        width: 24px;
        height: 24px;
        animation: spin 1s linear infinite;
        display: inline-block;
        margin-right: 8px;
      }

      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }

      /* File upload area */
      .file-upload-area {
        border: 2px dashed #d1d5db;
        border-radius: 8px;
        padding: 20px;
        text-align: center;
        background-color: #f9fafb;
        transition: border-color 0.2s;
      }

      .file-upload-area:hover {
        border-color: #10a37f;
      }

      /* Dropdown styling */
      .selectize-input {
        border: 1px solid #d1d5db;
        border-radius: 6px;
        padding: 8px 12px;
      }

      .selectize-input:focus {
        border-color: #10a37f;
      }

      /* Slider styling */
      .irs-bar {
        background: #10a37f;
      }

      .irs-from, .irs-to, .irs-single {
        background: #10a37f;
      }

      /* Scrollbar styling */
      ::-webkit-scrollbar {
        width: 8px;
      }

      ::-webkit-scrollbar-track {
        background: #f1f1f1;
      }

      ::-webkit-scrollbar-thumb {
        background: #888;
        border-radius: 4px;
      }

      ::-webkit-scrollbar-thumb:hover {
        background: #555;
      }

      /* Responsive adjustments */
      @media (max-width: 768px) {
        #chat_display {
          min-height: 300px;
          max-height: 400px;
        }
      }
    "))
  )

  # UI definition
  ui <- shinydashboard::dashboardPage(
    skin = "purple",

    # Header
    shinydashboard::dashboardHeader(
      title = "ALAQUER - AI Assistant",
      titleWidth = 300
    ),

    # Sidebar
    shinydashboard::dashboardSidebar(
      width = 300,
      shinydashboard::sidebarMenu(
        shinydashboard::menuItem("Chat", tabName = "chat", icon = shiny::icon("comments")),
        shinydashboard::menuItem("Knowledge Base", tabName = "knowledge", icon = shiny::icon("book")),
        shinydashboard::menuItem("Settings", tabName = "settings", icon = shiny::icon("cog")),
        shinydashboard::menuItem("About", tabName = "about", icon = shiny::icon("info-circle"))
      ),

      # Ollama Connection
      tags$hr(),
      tags$div(
        style = "padding: 0 15px;",
        tags$h4("Ollama Connection", style = "color: white; font-size: 14px;"),
        shiny::textInput(
          "ollama_host",
          "Host:",
          value = ollama_host,
          placeholder = "http://localhost:11434"
        ),
        shiny::actionButton(
          "refresh_models",
          "Refresh Models",
          icon = shiny::icon("sync"),
          class = "btn-secondary btn-sm",
          style = "width: 100%;"
        ),
        tags$br(),
        tags$br(),
        shiny::uiOutput("connection_status")
      ),

      # Model Selection
      tags$hr(),
      tags$div(
        style = "padding: 0 15px;",
        tags$h4("Model Settings", style = "color: white; font-size: 14px;"),
        shiny::selectInput(
          "selected_model",
          "Model:",
          choices = c("Loading..." = ""),
          width = "100%"
        ),
        shiny::sliderInput(
          "temperature",
          "Temperature:",
          min = 0,
          max = 2,
          value = 0.7,
          step = 0.1,
          width = "100%"
        ),
        shiny::sliderInput(
          "top_p",
          "Top P:",
          min = 0,
          max = 1,
          value = 0.9,
          step = 0.05,
          width = "100%"
        ),
        shiny::numericInput(
          "max_tokens",
          "Max Tokens:",
          value = 2000,
          min = 100,
          max = 8000,
          step = 100,
          width = "100%"
        )
      )
    ),

    # Main Body
    shinydashboard::dashboardBody(
      custom_css,
      shinyjs::useShinyjs(),

      shiny::tabItems(
        # Chat Tab
        shinydashboard::tabItem(
          tabName = "chat",

          # Main Chat Area
          shinydashboard::box(
            title = "Chat with AI",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            collapsible = FALSE,

            # Chat display
            shinycssloaders::withSpinner(
              shiny::uiOutput("chat_display"),
              type = 4,
              color = "#10a37f"
            ),

            # Input area
            tags$div(
              id = "query_input_container",
              shiny::textAreaInput(
                "query_input",
                NULL,
                placeholder = "Type your message here... (Press Enter to send, Shift+Enter for new line)",
                width = "100%",
                rows = 3
              ),

              # Action buttons row
              shiny::fluidRow(
                shiny::column(
                  6,
                  shiny::actionButton(
                    "send_query",
                    "Send",
                    icon = shiny::icon("paper-plane"),
                    class = "btn-primary",
                    style = "margin-right: 8px;"
                  ),
                  shiny::actionButton(
                    "stop_query",
                    "Stop",
                    icon = shiny::icon("stop"),
                    class = "btn-danger btn-sm"
                  )
                ),
                shiny::column(
                  6,
                  style = "text-align: right;",
                  shiny::actionButton(
                    "copy_response",
                    "Copy Last",
                    icon = shiny::icon("copy"),
                    class = "btn-secondary btn-sm",
                    style = "margin-right: 8px;"
                  ),
                  shiny::actionButton(
                    "reaskg_query",
                    "Re-ask",
                    icon = shiny::icon("redo"),
                    class = "btn-secondary btn-sm",
                    style = "margin-right: 8px;"
                  ),
                  shiny::actionButton(
                    "clear_chat",
                    "Clear",
                    icon = shiny::icon("trash"),
                    class = "btn-secondary btn-sm"
                  )
                )
              )
            )
          ),

          # Feature Panels Row
          shiny::fluidRow(
            # Prompt Engineering
            shiny::column(
              4,
              shinydashboard::box(
                title = "AI Prompt Enhancement",
                status = "info",
                solidHeader = TRUE,
                width = NULL,
                collapsible = TRUE,
                collapsed = TRUE,

                shiny::selectInput(
                  "prompt_length",
                  "Prompt Length:",
                  choices = c(
                    "Short" = "short",
                    "Medium" = "medium",
                    "Long" = "long",
                    "Very Long" = "very_long"
                  ),
                  selected = "medium"
                ),
                shiny::actionButton(
                  "enhance_prompt",
                  "Enhance Prompt",
                  icon = shiny::icon("magic"),
                  class = "btn-secondary",
                  style = "width: 100%;"
                )
              )
            ),

            # Example Prompts
            shiny::column(
              4,
              shinydashboard::box(
                title = "Example Prompts",
                status = "info",
                solidHeader = TRUE,
                width = NULL,
                collapsible = TRUE,
                collapsed = TRUE,

                shiny::selectInput(
                  "prompt_category",
                  "Category:",
                  choices = c("Loading..." = ""),
                  width = "100%"
                ),
                shiny::selectInput(
                  "example_prompt",
                  "Select Prompt:",
                  choices = c("Choose a category first" = ""),
                  width = "100%"
                ),
                shiny::actionButton(
                  "use_example",
                  "Use This Prompt",
                  icon = shiny::icon("arrow-right"),
                  class = "btn-secondary",
                  style = "width: 100%;"
                )
              )
            ),

            # Online Search
            shiny::column(
              4,
              shinydashboard::box(
                title = "Online Search",
                status = "info",
                solidHeader = TRUE,
                width = NULL,
                collapsible = TRUE,
                collapsed = TRUE,

                shiny::checkboxGroupInput(
                  "search_sources",
                  "Sources:",
                  choices = c(
                    "DuckDuckGo" = "duckduckgo",
                    "Wikipedia" = "wikipedia"
                  ),
                  selected = c("duckduckgo", "wikipedia")
                ),
                shiny::checkboxInput(
                  "use_online_search",
                  "Include in query",
                  value = FALSE
                ),
                shiny::numericInput(
                  "max_search_results",
                  "Max results:",
                  value = 3,
                  min = 1,
                  max = 10
                )
              )
            )
          )
        ),

        # Knowledge Base Tab
        shinydashboard::tabItem(
          tabName = "knowledge",

          shinydashboard::box(
            title = "Knowledge Base Management",
            status = "primary",
            solidHeader = TRUE,
            width = 12,

            shiny::fluidRow(
              shiny::column(
                6,
                tags$h4("Upload Documents"),
                tags$div(
                  class = "file-upload-area",
                  shiny::fileInput(
                    "kb_files",
                    NULL,
                    multiple = TRUE,
                    accept = c(".txt", ".pdf", ".csv", ".xlsx", ".xls", ".md", ".rmd"),
                    buttonLabel = "Choose Files",
                    placeholder = "No files selected"
                  )
                ),
                tags$p(
                  "Supported formats: TXT, PDF, CSV, Excel, Markdown",
                  style = "color: #6b7280; font-size: 13px;"
                ),
                shiny::actionButton(
                  "process_kb",
                  "Process Documents",
                  icon = shiny::icon("cogs"),
                  class = "btn-primary"
                ),
                tags$br(),
                tags$br(),
                shiny::checkboxInput(
                  "use_knowledge_base",
                  "Use Knowledge Base in queries",
                  value = FALSE
                )
              ),

              shiny::column(
                6,
                tags$h4("Knowledge Base Status"),
                shiny::uiOutput("kb_status"),
                tags$br(),
                shiny::actionButton(
                  "clear_kb",
                  "Clear Knowledge Base",
                  icon = shiny::icon("trash"),
                  class = "btn-danger"
                )
              )
            ),

            tags$hr(),

            tags$h4("Document List"),
            DT::dataTableOutput("kb_documents_table")
          )
        ),

        # Settings Tab
        shinydashboard::tabItem(
          tabName = "settings",

          shinydashboard::box(
            title = "Application Settings",
            status = "primary",
            solidHeader = TRUE,
            width = 12,

            shiny::fluidRow(
              shiny::column(
                6,
                tags$h4("Response Processing"),
                shiny::checkboxInput(
                  "format_code",
                  "Format code blocks",
                  value = TRUE
                ),
                shiny::checkboxInput(
                  "highlight_terms",
                  "Highlight technical terms",
                  value = TRUE
                ),
                shiny::checkboxInput(
                  "structure_text",
                  "Improve text structure",
                  value = TRUE
                ),
                shiny::selectInput(
                  "response_length",
                  "Response length optimization:",
                  choices = c(
                    "Concise" = "concise",
                    "Normal" = "normal",
                    "Detailed" = "detailed"
                  ),
                  selected = "normal"
                )
              ),

              shiny::column(
                6,
                tags$h4("Advanced Options"),
                shiny::numericInput(
                  "chunk_size",
                  "KB Chunk Size:",
                  value = 500,
                  min = 100,
                  max = 2000,
                  step = 100
                ),
                shiny::numericInput(
                  "chunk_overlap",
                  "KB Chunk Overlap:",
                  value = 100,
                  min = 0,
                  max = 500,
                  step = 50
                ),
                shiny::numericInput(
                  "kb_max_results",
                  "KB Max Results:",
                  value = 3,
                  min = 1,
                  max = 10
                )
              )
            ),

            tags$hr(),

            shiny::fluidRow(
              shiny::column(
                12,
                shiny::actionButton(
                  "export_chat",
                  "Export Chat to Markdown",
                  icon = shiny::icon("download"),
                  class = "btn-secondary"
                ),
                shiny::downloadButton(
                  "download_chat",
                  "Download",
                  class = "btn-secondary",
                  style = "margin-left: 8px;"
                )
              )
            )
          ),

          shinydashboard::box(
            title = "System Requirements",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            collapsible = TRUE,

            shiny::verbatimTextOutput("system_requirements")
          )
        ),

        # About Tab
        shinydashboard::tabItem(
          tabName = "about",

          shinydashboard::box(
            title = "About ALAQUER",
            status = "primary",
            solidHeader = TRUE,
            width = 12,

            tags$div(
              style = "padding: 20px;",
              tags$h3("ALAQUER"),
              tags$h4("Advanced Language AI Query User Experience in R"),
              tags$p(
                "Version 1.0.0",
                style = "color: #6b7280;"
              ),
              tags$br(),

              tags$h4("Features"),
              tags$ul(
                tags$li("ChatGPT-style interface for Ollama models"),
                tags$li("Super RAG with semantic chunking and hybrid search"),
                tags$li("AI-powered prompt engineering"),
                tags$li("Online search integration (DuckDuckGo, Wikipedia)"),
                tags$li("Advanced response processing and formatting"),
                tags$li("150+ professional example prompts"),
                tags$li("Document upload and knowledge base management"),
                tags$li("Real-time chat with conversation history"),
                tags$li("Customizable model parameters")
              ),

              tags$br(),
              tags$h4("License"),
              tags$p("MIT License - Copyright (c) 2025 ALAQUER Developers"),

              tags$br(),
              tags$h4("Support"),
              tags$p(
                "For issues and questions, please visit the GitHub repository or documentation."
              )
            )
          )
        )
      )
    )
  )

  return(ui)
}

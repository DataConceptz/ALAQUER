# ALAQUER 🚀

**A**dvanced **L**anguage **A**I **Q**uery **U**ser **E**xperience in **R**

<div align="center">

[![R](https://img.shields.io/badge/R-%3E%3D4.0.0-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ollama](https://img.shields.io/badge/Powered%20by-Ollama-black.svg)](https://ollama.ai/)

*A cutting-edge R package and RStudio addin that provides a sophisticated ChatGPT-style Shiny interface for interacting with Ollama language models*

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Usage Guide](#-usage-guide)
- [Advanced Features](#-advanced-features)
- [Troubleshooting](#-troubleshooting)
- [API Reference](#-api-reference)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

ALAQUER is a powerful R package that brings state-of-the-art AI capabilities to your R environment. It provides a beautiful, intuitive ChatGPT-style interface for seamless interaction with local Ollama language models, enhanced with cutting-edge features like Super RAG, AI-powered prompt engineering, and online search integration.

### Why ALAQUER?

- 🎯 **No API Keys Required** - Uses local Ollama models
- 🔒 **Privacy-Focused** - All data stays on your machine
- 💪 **Powerful Features** - RAG, prompt engineering, online search
- 🎨 **Beautiful UI** - Modern, professional ChatGPT-style interface
- 📚 **Rich Library** - 150+ professional prompts across 10 categories
- 🚀 **Easy to Use** - Simple installation and setup

---

## ✨ Features

### 🔧 **AI-Powered Prompt Engineering**
- **Smart Prompt Enhancement**: Transform basic keywords into professional, optimized prompts
- **Multiple Length Options**: Short, Medium, Long, and Very Long prompt styles
- **Context-Aware**: Uses your selected Ollama model for intelligent prompt rewriting
- **Best Practices**: Automatically applies prompt engineering best practices

### 📝 **Example Prompts Library**
- **150+ Professional Prompts**: Across 10 comprehensive categories
- **Easy Selection**: Dropdown menus for quick prompt selection
- **Categories Include**:
  - 📊 Data Analysis (20 prompts)
  - 🎓 Academic Research (15 prompts)
  - ✍️ Creative Writing (15 prompts)
  - 💼 Business Strategy (15 prompts)
  - 🔧 Technical Support (15 prompts)
  - 💻 Code Development (20 prompts)
  - 📚 Learning & Education (15 prompts)
  - 📱 Content Creation (15 prompts)
  - 🧩 Problem Solving (15 prompts)
  - 🌱 Personal Development (15 prompts)

### 📚 **Super RAG (Enhanced Knowledge Base)**
- **Semantic Chunking**: Advanced text processing with intelligent overlap
- **Hybrid Search**: Combines keyword, entity, and semantic search
- **Enhanced Metadata**: Automatic extraction of keywords, entities, and document classification
- **Smart Ranking**: Multi-factor relevance scoring for better results
- **Multi-Format Support**: TXT, PDF, CSV, Excel, Markdown

### 🌐 **Online Search Integration**
- **Real-Time Web Search**: Fetch current information from DuckDuckGo and Wikipedia
- **Domain Filtering**: Specify preferred domains for targeted searches
- **Content Summarization**: Automatic summarization of web content
- **Relevance Scoring**: Intelligent ranking of search results

### ✨ **Advanced Response Processing**
- **Intelligent Formatting**: Automatic text structure improvement
- **Code Enhancement**: Smart detection and formatting of code blocks
- **Technical Terms**: Automatic highlighting of technical terminology
- **Response Optimization**: Length and readability optimization

### 🎯 **Core Functionality**
- **ChatGPT-Style Interface**: Professional, intuitive UI with sidebar controls
- **Ollama Integration**: Direct connection to local Ollama instances
- **Real-time Chat**: Interactive conversation interface with message history
- **Model Configuration**: Adjustable parameters (temperature, top_p, max tokens)
- **Copy & Export**: One-click copying and Markdown export
- **Connection Monitoring**: Real-time Ollama connection status

---

## 📦 Prerequisites

Before installing ALAQUER, ensure you have the following:

### 1. R (>= 4.0.0)

Check your R version:

```r
R.version.string
```

If you need to upgrade, download from [r-project.org](https://www.r-project.org/)

### 2. Ollama

ALAQUER requires Ollama to be installed and running on your system.

#### Installation Instructions by Platform:

**macOS:**
```bash
# Download and install from https://ollama.ai/
# Or use Homebrew:
brew install ollama
```

**Linux:**
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**Windows:**
Download the installer from [ollama.ai](https://ollama.ai/)

#### Start Ollama:
```bash
ollama serve
```

#### Pull at least one model:
```bash
# Recommended models:
ollama pull llama2        # General purpose
ollama pull codellama     # Code-focused
ollama pull mistral       # Fast and capable
ollama pull llama3        # Latest version
```

### 3. Required R Packages

ALAQUER will automatically install these if missing:
- shiny, shinydashboard, shinyWidgets, shinyjs, shinycssloaders
- DT, httr, jsonlite, clipr
- readr, readxl, pdftools, tm
- stringr, dplyr, tidyr
- markdown, rmarkdown, xml2, rvest

---

## 🚀 Installation

### Method 1: Automated Installation (Recommended)

1. **Clone or download the ALAQUER repository:**

```bash
git clone https://github.com/yourusername/ALAQUER.git
cd ALAQUER
```

2. **Run the automated installation script:**

```r
# In R console, navigate to ALAQUER directory
setwd("path/to/ALAQUER")

# Run installation and testing
source("install_and_test.R")
```

This will:
- ✅ Check R version compatibility
- ✅ Install all required dependencies
- ✅ Load ALAQUER functions
- ✅ Run basic tests
- ✅ Verify Ollama connection
- ✅ Display next steps

### Method 2: Manual Installation

1. **Navigate to ALAQUER directory:**

```r
setwd("path/to/ALAQUER")
```

2. **Install dependencies:**

```r
# List of required packages
required_packages <- c(
  "shiny", "shinydashboard", "shinyWidgets", "shinyjs", "shinycssloaders",
  "DT", "httr", "jsonlite", "clipr", "readr", "readxl",
  "pdftools", "tm", "stringr", "dplyr", "tidyr",
  "markdown", "rmarkdown", "xml2", "rvest", "curl", "digest"
)

# Install missing packages
install.packages(required_packages)
```

3. **Load ALAQUER:**

```r
# Load all R files
r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
for (file in r_files) {
  source(file)
}
```

### Method 3: Install as R Package

```r
# Install devtools if needed
install.packages("devtools")

# Install ALAQUER from local source
devtools::install("path/to/ALAQUER")

# Load the package
library(ALAQUER)
```

### Method 4: Quick Fix Installation

If you encounter any issues:

```r
setwd("path/to/ALAQUER")
source("complete_fix.R")
```

This comprehensive script will:
- Update all packages
- Fix common installation issues
- Verify system requirements
- Test Ollama connection

---

## 🎯 Quick Start

### Basic Launch

ALAQUER can be launched in multiple ways depending on your environment:

#### **Option 1: RStudio Addins Menu** (Recommended for RStudio users)

After installation, simply:
1. Click **"Addins"** in the RStudio toolbar
2. Select **"ALAQUER - AI Assistant"**
3. The application launches automatically!

#### **Option 2: R Function Call** (Works everywhere)

```r
# If installed as package
library(ALAQUER)
launch_alaquer()

# Or call directly
ALAQUER::launch_alaquer()
```

#### **Option 3: Quick Launch Script** (Development mode)

```r
# Navigate to ALAQUER directory
setwd("path/to/ALAQUER")

# Quick launch
source("quick_launch.R")
```

#### **Option 4: Manual Launch**

```r
setwd("path/to/ALAQUER")
source("R/launch_app.R")
launch_alaquer()
```

### First-Time Setup Checklist

- [ ] Ollama is installed and running (`ollama serve`)
- [ ] At least one model is pulled (`ollama pull llama2`)
- [ ] R version is 4.0.0 or higher
- [ ] All dependencies are installed
- [ ] You're in the ALAQUER directory

### Verify System Readiness

```r
# Check if everything is ready
check_alaquer_ready()

# Install any missing dependencies
install_alaquer_dependencies()
```

---

## 📖 Usage Guide

### 1. Starting the Application

After launching ALAQUER, a browser window will open with the interface:

```r
launch_alaquer()
# Or with custom settings:
launch_alaquer(
  host = "127.0.0.1",
  port = 3838,
  ollama_host = "http://localhost:11434"
)
```

### 2. Basic Chat Interaction

1. **Select a Model**: Choose from available Ollama models in the sidebar
2. **Type Your Query**: Enter your question in the input box
3. **Send**: Click "Send" or press Enter
4. **View Response**: AI response appears in the chat area

**Keyboard Shortcuts:**
- `Enter`: Send message
- `Shift + Enter`: New line in input

### 3. Using Example Prompts

1. Click the **"Example Prompts"** panel
2. Select a **category** (e.g., Data Analysis)
3. Choose a **specific prompt** from the dropdown
4. Click **"Use This Prompt"**
5. Edit if needed and send

### 4. AI-Powered Prompt Enhancement

Transform simple keywords into professional prompts:

1. Type basic keywords or a rough idea
2. Select desired **prompt length** (Short/Medium/Long/Very Long)
3. Click **"Enhance Prompt"**
4. AI rewrites your prompt with best practices
5. Review, edit, and send

**Example:**
```
Input: "machine learning basics"

Enhanced Output (Medium):
"Provide a comprehensive introduction to machine learning
covering fundamental concepts, key algorithms, and practical
applications. Include explanations of supervised vs unsupervised
learning with relevant examples."
```

### 5. Knowledge Base (Super RAG)

Upload documents and query them:

1. Go to **"Knowledge Base"** tab
2. Click **"Choose Files"** and select documents
3. Click **"Process Documents"**
4. Enable **"Use Knowledge Base in queries"**
5. Ask questions about your documents

**Supported Formats:**
- Text files (.txt)
- PDFs (.pdf)
- CSV files (.csv)
- Excel files (.xlsx, .xls)
- Markdown (.md, .rmd)

**Example Workflow:**
```r
# Upload research papers → Enable KB → Ask:
"What are the main findings in the uploaded papers about neural networks?"
```

### 6. Online Search Integration

Enhance queries with real-time web information:

1. Expand **"Online Search"** panel
2. Select sources (DuckDuckGo, Wikipedia, or both)
3. Enable **"Include in query"**
4. Set max results (1-10)
5. Your queries will now include current web information

**Use Cases:**
- Current events and news
- Latest documentation
- Recent research findings
- Real-time data

### 7. Model Configuration

Fine-tune AI behavior in the sidebar:

**Temperature (0-2):**
- `0.0-0.3`: Focused, deterministic responses
- `0.4-0.7`: Balanced creativity and consistency
- `0.8-2.0`: Creative, varied responses

**Top P (0-1):**
- Lower values: More conservative word choices
- Higher values: More diverse vocabulary

**Max Tokens:**
- Control response length (100-8000)

### 8. Advanced Features

**Copy Last Response:**
- Click "Copy Last" to copy AI response to clipboard

**Re-ask Last Query:**
- Click "Re-ask" to reload previous question

**Clear Chat:**
- Click "Clear" to start fresh conversation

**Export Chat:**
- Settings → "Export Chat to Markdown"
- Downloads conversation history as .md file

**Stop Query:**
- Click "Stop" to halt long-running queries

---

## 🔥 Advanced Features

### Programmatic Use

Use ALAQUER functions directly in your R scripts:

```r
# Direct Ollama query
response <- ollama_query(
  prompt = "Explain machine learning",
  model = "llama2",
  temperature = 0.7,
  max_tokens = 500
)
print(response$text)

# Create knowledge base
kb <- create_knowledge_base(
  file_paths = c("doc1.pdf", "doc2.txt"),
  kb_name = "my_kb"
)

# Search knowledge base
results <- search_knowledge_base(
  kb = kb,
  query = "neural networks",
  max_results = 5
)

# Enhance prompt
enhanced <- enhance_prompt(
  input = "data analysis",
  length = "long",
  model = "llama2"
)

# Online search
search_results <- search_online(
  query = "latest AI developments",
  sources = c("duckduckgo", "wikipedia"),
  max_results = 5
)

# Process response
processed <- process_response(
  text = raw_response,
  options = list(
    format_code = TRUE,
    highlight_terms = TRUE
  )
)
```

### Custom Configuration

```r
# Check system requirements
reqs <- check_system_requirements()
print(reqs)

# Get available models
models <- get_ollama_models("http://localhost:11434")
print(models)

# Check Ollama connection
is_connected <- check_ollama_connection()
```

### Batch Processing

```r
# Process multiple documents
files <- c("paper1.pdf", "paper2.pdf", "paper3.pdf")
kb <- create_knowledge_base(
  file_paths = files,
  chunk_size = 500,
  overlap = 100
)

# Query each document
queries <- c("What is the main hypothesis?",
             "What methodology was used?",
             "What were the key findings?")

results <- lapply(queries, function(q) {
  search_knowledge_base(kb, q, max_results = 3)
})
```

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. "Cannot connect to Ollama"

**Problem**: ALAQUER can't reach Ollama server

**Solutions:**
```bash
# Check if Ollama is running
ps aux | grep ollama

# Start Ollama
ollama serve

# Test connection
curl http://localhost:11434/api/tags
```

**In ALAQUER:**
```r
# Verify connection
check_ollama_connection("http://localhost:11434")

# Try different host if needed
launch_alaquer(ollama_host = "http://127.0.0.1:11434")
```

#### 2. "No models available"

**Problem**: No Ollama models installed

**Solution:**
```bash
# List available models
ollama list

# Pull a model
ollama pull llama2

# Verify in ALAQUER
get_ollama_models("http://localhost:11434")
```

#### 3. Package Installation Errors

**Problem**: Dependencies fail to install

**Solution:**
```r
# Run fix script
source("complete_fix.R")

# Or install manually
install_alaquer_dependencies(upgrade = TRUE)

# Check specific package
install.packages("problematic_package", dependencies = TRUE)
```

#### 4. "File upload failed" or "No valid documents"

**Problem**: Document processing errors

**Solutions:**
- Check file format is supported (TXT, PDF, CSV, Excel, Markdown)
- Ensure files are not corrupted
- Try smaller files first
- Check file permissions

```r
# Test file reading
test_text <- extract_document_text("your_file.pdf")
print(test_text)
```

#### 5. Application won't start

**Problem**: Shiny app fails to launch

**Solutions:**
```r
# Check R version
R.version.string  # Must be >= 4.0.0

# Verify all packages loaded
check_system_requirements()

# Clear workspace and retry
rm(list = ls())
source("quick_launch.R")
```

#### 6. Slow performance

**Solutions:**
- Use smaller documents for knowledge base
- Reduce max tokens for faster responses
- Close other applications using GPU/CPU
- Use lighter Ollama models (e.g., `mistral` instead of `llama2:70b`)

```r
# Launch with lighter model
launch_alaquer()
# Then select a smaller model in UI
```

### Getting Help

**Error Logs:**
```r
# Enable verbose output
options(shiny.trace = TRUE)
launch_alaquer()
```

**System Check:**
```r
# Run comprehensive check
check_alaquer_ready(verbose = TRUE)
```

**Test Individual Components:**
```r
# Test Ollama
ollama_query("test", "llama2")

# Test knowledge base
kb <- create_knowledge_base("test.txt")

# Test search
search_online("test query")
```

---

## 📚 API Reference

### Main Functions

#### `launch_alaquer()`
Launch the ALAQUER Shiny application

```r
launch_alaquer(
  host = "127.0.0.1",
  port = NULL,
  launch.browser = TRUE,
  ollama_host = "http://localhost:11434"
)
```

#### `ollama_query()`
Send a query to Ollama model

```r
ollama_query(
  prompt,
  model,
  host = "http://localhost:11434",
  temperature = 0.7,
  top_p = 0.9,
  max_tokens = 2000
)
```

#### `create_knowledge_base()`
Create enhanced knowledge base from documents

```r
create_knowledge_base(
  file_paths,
  kb_name = "default",
  chunk_size = 500,
  overlap = 100
)
```

#### `search_knowledge_base()`
Search knowledge base with hybrid search

```r
search_knowledge_base(
  kb,
  query,
  max_results = 5,
  min_score = 0.1
)
```

#### `enhance_prompt()`
AI-powered prompt enhancement

```r
enhance_prompt(
  input,
  length = "medium",
  model,
  host = "http://localhost:11434"
)
```

#### `search_online()`
Search web with DuckDuckGo and Wikipedia

```r
search_online(
  query,
  sources = c("duckduckgo", "wikipedia"),
  max_results = 3,
  domains = NULL
)
```

#### `process_response()`
Process and enhance AI responses

```r
process_response(
  text,
  options = list(
    format_code = TRUE,
    highlight_terms = TRUE,
    structure_text = TRUE
  )
)
```

### Utility Functions

```r
# System checks
check_system_requirements()
check_alaquer_ready()
check_ollama_connection()

# Model management
get_ollama_models()
pull_ollama_model()

# Prompts
get_example_prompts()
get_prompt_categories()
search_example_prompts()

# Dependencies
install_alaquer_dependencies()
```

For complete documentation:
```r
?launch_alaquer
?ALAQUER
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Reporting Issues

- Use GitHub Issues
- Include R version, OS, and Ollama version
- Provide reproducible example
- Include error messages

### Development Setup

```r
# Clone repository
git clone https://github.com/yourusername/ALAQUER.git
cd ALAQUER

# Create feature branch
git checkout -b feature/your-feature

# Make changes and test
source("install_and_test.R")

# Commit and push
git commit -m "Add feature"
git push origin feature/your-feature
```

### Adding Example Prompts

Edit `R/example_prompts.R`:
```r
# Add to appropriate category
prompts = c(
  "Your new professional prompt here...",
  # ... existing prompts
)
```

### Code Style

- Follow R best practices
- Comment complex logic
- Include roxygen2 documentation
- Test before submitting

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 ALAQUER Developers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Acknowledgments

- **[Ollama](https://ollama.ai/)** - For providing the local LLM infrastructure
- **[Shiny](https://shiny.rstudio.com/)** - For the web application framework
- **R Community** - For the excellent package ecosystem
- **Contributors** - Thank you to all who have contributed!

---

## 📊 Project Stats

- **Lines of Code**: 4,600+
- **R Modules**: 10
- **Example Prompts**: 150+
- **Supported File Formats**: 5
- **Features**: 10+ major features
- **Dependencies**: 23 packages

---

## 🗺️ Roadmap

### Planned Features

- [ ] Vector database integration (ChromaDB, Pinecone)
- [ ] Support for more LLM providers (OpenAI, Anthropic, etc.)
- [ ] Multi-language support
- [ ] Custom theme builder
- [ ] Conversation templates
- [ ] API endpoints for programmatic access
- [ ] Plugin system for extensions
- [ ] Mobile-responsive improvements
- [ ] Voice input/output
- [ ] Advanced analytics dashboard

---

## 📞 Support

- **Documentation**: See this README and `?ALAQUER`
- **Issues**: [GitHub Issues](https://github.com/yourusername/ALAQUER/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/ALAQUER/discussions)

---

## ⭐ Star History

If you find ALAQUER useful, please consider giving it a star on GitHub!

---

<div align="center">

**ALAQUER** - Making AI interaction in R as smooth as possible! 🚀

Built with ❤️ by the ALAQUER Team

[⬆ Back to Top](#alaquer-)

</div>

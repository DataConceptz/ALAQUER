# ALAQUER Installation Guide

Complete installation instructions for ALAQUER (Advanced Language AI Query User Experience in R)

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Install Prerequisites](#install-prerequisites)
3. [Install ALAQUER](#install-alaquer)
4. [Verify Installation](#verify-installation)
5. [Troubleshooting](#troubleshooting)
6. [Platform-Specific Instructions](#platform-specific-instructions)

---

## System Requirements

### Minimum Requirements

- **R**: Version 4.0.0 or higher
- **RAM**: 4 GB minimum, 8 GB recommended
- **Disk Space**: 2 GB free space (for Ollama models)
- **OS**: Windows 10+, macOS 10.15+, or Linux

### Check Your R Version

```r
# In R console
R.version.string
```

If your version is below 4.0.0, download the latest from [r-project.org](https://www.r-project.org/)

---

## Install Prerequisites

### Step 1: Install Ollama

Ollama is required for ALAQUER to function.

#### macOS

**Option A: Direct Download**
1. Visit [https://ollama.ai/](https://ollama.ai/)
2. Download the macOS installer
3. Open the .dmg file and drag Ollama to Applications
4. Launch Ollama from Applications

**Option B: Homebrew**
```bash
brew install ollama
```

#### Linux

**Ubuntu/Debian:**
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**Manual Installation:**
```bash
# Download binary
curl -L https://ollama.ai/download/ollama-linux-amd64 -o ollama
chmod +x ollama
sudo mv ollama /usr/local/bin/
```

#### Windows

1. Visit [https://ollama.ai/](https://ollama.ai/)
2. Download the Windows installer
3. Run the installer and follow prompts
4. Ollama will start automatically

### Step 2: Start Ollama

```bash
# Start Ollama server
ollama serve
```

Keep this terminal window open. Ollama needs to be running for ALAQUER to work.

### Step 3: Install at Least One Model

```bash
# Recommended for general use (4GB)
ollama pull llama2

# Alternative models:
ollama pull mistral      # Fast and capable (4GB)
ollama pull codellama    # Best for code (7GB)
ollama pull llama3       # Latest version (4GB)
ollama pull phi          # Small and fast (1.6GB)
```

**Verify models are installed:**
```bash
ollama list
```

---

## Install ALAQUER

### Method 1: Automated Installation (Recommended)

This is the easiest method for most users.

**Step 1: Get ALAQUER**

```bash
# Clone from GitHub
git clone https://github.com/yourusername/ALAQUER.git
cd ALAQUER

# Or download ZIP and extract
# Then navigate to the directory
cd path/to/ALAQUER
```

**Step 2: Run Installation Script**

```r
# In R console
setwd("path/to/ALAQUER")
source("install_and_test.R")
```

This script will:
- ✅ Check R version
- ✅ Install all required packages
- ✅ Load ALAQUER functions
- ✅ Run tests
- ✅ Verify Ollama connection

**Step 3: Launch ALAQUER**

```r
# Quick launch
source("quick_launch.R")
```

---

### Method 2: Manual Installation

For users who want more control over the installation process.

**Step 1: Navigate to ALAQUER Directory**

```r
setwd("path/to/ALAQUER")
```

**Step 2: Install Dependencies**

```r
# Define required packages
required_packages <- c(
  # Shiny packages
  "shiny",
  "shinydashboard",
  "shinyWidgets",
  "shinyjs",
  "shinycssloaders",

  # Data handling
  "DT",
  "dplyr",
  "tidyr",
  "readr",
  "readxl",

  # HTTP and JSON
  "httr",
  "jsonlite",
  "curl",

  # Text processing
  "tm",
  "stringr",
  "markdown",
  "rmarkdown",

  # Document processing
  "pdftools",

  # Web scraping
  "xml2",
  "rvest",

  # Utilities
  "clipr",
  "digest",
  "Matrix"
)

# Install packages
install.packages(required_packages, dependencies = TRUE)
```

**Step 3: Load ALAQUER**

```r
# Load all R source files
r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
for (file in r_files) {
  source(file)
}
```

**Step 4: Verify and Launch**

```r
# Check if ready
check_alaquer_ready()

# Launch application
launch_alaquer()
```

---

### Method 3: Install as R Package

For advanced users who want to install ALAQUER as a standard R package.

**Prerequisites:**
```r
install.packages("devtools")
```

**Installation:**

```r
# Install from local source
devtools::install("path/to/ALAQUER")

# Or install from GitHub (once published)
# devtools::install_github("yourusername/ALAQUER")
```

**Usage:**

```r
library(ALAQUER)
launch_alaquer()
```

---

### Method 4: Emergency Fix Installation

If you encounter any installation problems, use this comprehensive fix script.

```r
setwd("path/to/ALAQUER")
source("complete_fix.R")
```

This will:
- Update R package repositories
- Install/update all dependencies
- Fix common issues
- Verify Ollama connection
- Run system diagnostics

---

## Verify Installation

### Quick Verification

```r
# In R console
setwd("path/to/ALAQUER")
source("R/launch_app.R")

# Check system readiness
check_alaquer_ready(verbose = TRUE)
```

Expected output:
```
Checking ALAQUER readiness...

1. Checking R version... OK
2. Checking required packages... OK
3. Checking Ollama connection... OK
4. Checking Ollama models... OK (X models available)

✓ ALAQUER is ready to launch!
  Run: launch_alaquer()
```

### Full Test Suite

```r
# Run installation and testing script
source("install_and_test.R")
```

This runs comprehensive tests including:
- R version check
- Package availability
- Ollama connectivity
- Example prompts library
- Utility functions

### Test Individual Components

```r
# Test Ollama connection
check_ollama_connection()
# Should return: TRUE

# Test model availability
get_ollama_models()
# Should return: character vector of model names

# Test query functionality
response <- ollama_query(
  prompt = "Say hello",
  model = "llama2"
)
print(response$text)
# Should return: AI-generated greeting

# Test example prompts
prompts <- get_example_prompts()
length(prompts)
# Should return: 10 (number of categories)
```

---

## Troubleshooting

### Issue 1: "Cannot find Ollama"

**Symptoms:**
- `check_ollama_connection()` returns `FALSE`
- Error: "Cannot connect to Ollama"

**Solutions:**

1. **Verify Ollama is running:**
   ```bash
   # Check if process is running
   ps aux | grep ollama

   # If not running, start it
   ollama serve
   ```

2. **Test connection manually:**
   ```bash
   curl http://localhost:11434/api/tags
   ```

3. **Check firewall:**
   - Ensure port 11434 is not blocked
   - Add Ollama to firewall exceptions

4. **Try different host:**
   ```r
   # Try 127.0.0.1 instead of localhost
   check_ollama_connection("http://127.0.0.1:11434")
   ```

### Issue 2: Package Installation Fails

**Symptoms:**
- Error during `install.packages()`
- Missing package warnings

**Solutions:**

1. **Update R:**
   ```r
   # Check version
   R.version.string
   # If < 4.0.0, upgrade R
   ```

2. **Update packages:**
   ```r
   update.packages(ask = FALSE)
   ```

3. **Install from different repository:**
   ```r
   options(repos = c(CRAN = "https://cloud.r-project.org/"))
   install.packages("package_name")
   ```

4. **Install with dependencies:**
   ```r
   install.packages("package_name", dependencies = TRUE)
   ```

5. **Platform-specific issues:**

   **Linux - Missing system libraries:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install libcurl4-openssl-dev libssl-dev libxml2-dev

   # Fedora/RHEL
   sudo yum install libcurl-devel openssl-devel libxml2-devel
   ```

   **macOS - Xcode tools:**
   ```bash
   xcode-select --install
   ```

### Issue 3: Application Won't Start

**Symptoms:**
- Shiny app fails to launch
- Blank browser window

**Solutions:**

1. **Clear R environment:**
   ```r
   rm(list = ls())
   .rs.restartR()  # In RStudio
   ```

2. **Check port availability:**
   ```r
   # Try different port
   launch_alaquer(port = 8080)
   ```

3. **Disable browser auto-launch:**
   ```r
   launch_alaquer(launch.browser = FALSE)
   # Then manually navigate to http://localhost:port
   ```

4. **Check Shiny installation:**
   ```r
   packageVersion("shiny")
   # Should be >= 1.7.0

   # Reinstall if needed
   install.packages("shiny")
   ```

### Issue 4: Models Not Appearing

**Symptoms:**
- Model dropdown is empty
- "No models available" warning

**Solutions:**

1. **Pull a model:**
   ```bash
   ollama pull llama2
   ```

2. **Verify models:**
   ```bash
   ollama list
   ```

3. **Refresh models in ALAQUER:**
   - Click "Refresh Models" button in sidebar
   - Or restart application

4. **Check model directory:**
   ```bash
   # macOS/Linux
   ls ~/.ollama/models

   # Windows
   dir %USERPROFILE%\.ollama\models
   ```

### Issue 5: File Upload Errors

**Symptoms:**
- "No valid documents could be processed"
- File upload fails

**Solutions:**

1. **Check file format:**
   - Supported: TXT, PDF, CSV, XLSX, XLS, MD, RMD
   - Ensure file extension is correct

2. **Check file size:**
   - Start with smaller files (< 10 MB)
   - Process large files one at a time

3. **Check file permissions:**
   ```bash
   # Linux/macOS
   ls -l your_file.pdf
   chmod 644 your_file.pdf  # If needed
   ```

4. **Test file reading:**
   ```r
   # Test if file can be read
   text <- extract_document_text("your_file.pdf")
   print(nchar(text))
   ```

### Issue 6: Slow Performance

**Solutions:**

1. **Use smaller models:**
   ```bash
   ollama pull phi  # Smallest model
   ```

2. **Reduce token limit:**
   - In ALAQUER settings, set Max Tokens to 500-1000

3. **Limit knowledge base:**
   - Use smaller documents
   - Reduce chunk count

4. **Close other applications:**
   - Free up RAM and CPU
   - Especially other AI/ML applications

5. **Check system resources:**
   ```bash
   # Monitor usage
   top  # Linux/macOS
   Task Manager  # Windows
   ```

---

## Platform-Specific Instructions

### Windows

**Installation Notes:**
- Use RStudio or RGui
- Run R as Administrator if permission errors occur
- Ollama runs as Windows service

**Common Issues:**
- Antivirus may block Ollama - add exception
- Windows Defender may flag downloads - allow
- Path length limits - install in short path (e.g., C:\ALAQUER)

### macOS

**Installation Notes:**
- Xcode command line tools may be required
- Homebrew recommended for Ollama
- May need to allow Ollama in Security settings

**Common Issues:**
- Gatekeeper warnings - Right-click → Open for first run
- Permission errors - Check System Preferences → Security & Privacy
- M1/M2 Macs - Use ARM-compatible Ollama version

### Linux

**Installation Notes:**
- Package dependencies vary by distribution
- May need to install system libraries
- Consider systemd service for Ollama

**Common Issues:**
- Missing system libraries - install development packages
- Permission errors - check user groups
- Firewall - configure iptables/ufw if needed

**Ubuntu/Debian:**
```bash
# Install system dependencies
sudo apt-get update
sudo apt-get install -y \
  r-base-dev \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  libpoppler-cpp-dev
```

**Fedora/RHEL:**
```bash
# Install system dependencies
sudo yum install -y \
  R-devel \
  libcurl-devel \
  openssl-devel \
  libxml2-devel \
  poppler-cpp-devel
```

---

## Post-Installation

### Configure Ollama to Start on Boot

**macOS/Linux (systemd):**
```bash
# Create service file
sudo tee /etc/systemd/system/ollama.service > /dev/null <<EOF
[Unit]
Description=Ollama Service
After=network.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=$USER
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl enable ollama
sudo systemctl start ollama
```

**macOS (launchd):**
```bash
# Ollama app starts automatically when installed
# Or create launch agent if using CLI version
```

**Windows:**
```
Ollama runs as Windows service automatically
Configure in Services (services.msc)
```

### Update ALAQUER

```bash
cd path/to/ALAQUER
git pull origin main
```

Then in R:
```r
source("install_and_test.R")
```

### Uninstall

```r
# Remove R packages (optional)
remove.packages(c("ALAQUER", "shiny", ...))

# Delete ALAQUER directory
# Manual deletion of folder

# Uninstall Ollama
# macOS: Delete from Applications
# Linux: sudo rm /usr/local/bin/ollama
# Windows: Use Add/Remove Programs
```

---

## Quick Reference

### Essential Commands

```r
# Setup
setwd("path/to/ALAQUER")
source("install_and_test.R")

# Launch
source("quick_launch.R")

# Or
launch_alaquer()

# Check status
check_alaquer_ready()

# Fix issues
source("complete_fix.R")
```

### Essential Ollama Commands

```bash
# Start Ollama
ollama serve

# List models
ollama list

# Pull model
ollama pull llama2

# Remove model
ollama rm llama2

# Check version
ollama --version
```

---

## Getting Help

If you continue to have issues:

1. **Read the full README**: `README.md`
2. **Check documentation**: In R, run `?launch_alaquer`
3. **Run diagnostics**: `check_alaquer_ready(verbose = TRUE)`
4. **Review logs**: Check R console output
5. **Search issues**: GitHub Issues page
6. **Ask for help**: Create new GitHub Issue with:
   - R version
   - Operating system
   - Error messages
   - Steps to reproduce

---

## Success Checklist

Before considering installation complete:

- [ ] R version >= 4.0.0
- [ ] Ollama installed and running
- [ ] At least one Ollama model pulled
- [ ] All R dependencies installed
- [ ] `check_alaquer_ready()` returns success
- [ ] Application launches in browser
- [ ] Can send and receive messages
- [ ] Can select different models

---

## Next Steps

After successful installation:

1. Read the [Usage Guide](README.md#usage-guide)
2. Try [Example Prompts](README.md#example-prompts-library)
3. Explore [Advanced Features](README.md#advanced-features)
4. Check out [API Reference](README.md#api-reference)

---

**Installation complete! Ready to use ALAQUER! 🚀**

For more information, see the main [README.md](README.md)

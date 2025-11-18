# ALAQUER Quick Start Guide ⚡

Get ALAQUER running in **5 minutes**!

---

## 🚀 Super Fast Start (3 Steps)

### Step 1: Install Ollama (2 minutes)

**macOS:**
```bash
brew install ollama
```

**Linux:**
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**Windows:**
Download from [ollama.ai](https://ollama.ai/)

### Step 2: Pull a Model (1 minute)

```bash
# Start Ollama
ollama serve

# In another terminal, pull a model
ollama pull llama2
```

### Step 3: Launch ALAQUER (1 minute)

```r
# In R console
setwd("path/to/ALAQUER")
source("install_and_test.R")
```

**Done! 🎉** Your browser will open with ALAQUER ready to use.

---

## 🚀 Launch Options

ALAQUER works as both a package AND an RStudio addin!

### **In RStudio (Easiest!):**
1. Click **Addins** → **ALAQUER - AI Assistant**
2. Done! 🎉

### **In Any R Environment:**
```r
library(ALAQUER)
launch_alaquer()
```

### **From Source Directory:**
```r
setwd("path/to/ALAQUER")
source("quick_launch.R")
```

---

## 📝 Absolute Minimum Example

If you just want to try it RIGHT NOW:

```bash
# Terminal 1: Start Ollama
ollama serve

# Terminal 2: Get a model
ollama pull phi  # Smallest model (1.6GB)
```

```r
# R Console
setwd("path/to/ALAQUER")
source("quick_launch.R")
```

That's it! Type a message and chat with AI.

---

## 🎯 Common First Tasks

### 1. Basic Chat
1. Type: "Explain machine learning in simple terms"
2. Press Enter
3. Wait for AI response

### 2. Try an Example Prompt
1. Click **"Example Prompts"** panel
2. Select **"Data Analysis"** category
3. Choose any prompt
4. Click **"Use This Prompt"**
5. Send!

### 3. Upload a Document
1. Go to **"Knowledge Base"** tab
2. Upload a PDF or text file
3. Enable **"Use Knowledge Base"**
4. Ask: "Summarize this document"

### 4. Use AI Prompt Enhancement
1. Type: "data science"
2. Click **"Enhance Prompt"**
3. See your simple input become a professional prompt!

---

## ⚙️ Quick Settings

**In the sidebar, you can:**

- **Select Model**: Choose from available Ollama models
- **Temperature** (0-2): Lower = focused, Higher = creative
- **Max Tokens**: Longer = more detailed responses

**Recommended for beginners:**
- Temperature: 0.7
- Top P: 0.9
- Max Tokens: 1000

---

## 🆘 Quick Troubleshooting

### "Cannot connect to Ollama"

```bash
# Make sure Ollama is running
ollama serve
```

### "No models available"

```bash
# Pull a model
ollama pull llama2
```

### "Package errors"

```r
# Run the fix script
source("complete_fix.R")
```

### App won't start

```r
# Clear everything and retry
rm(list = ls())
source("install_and_test.R")
```

---

## 📚 Next Steps

Once you're comfortable:

1. **Read the full guide**: [README.md](README.md)
2. **Explore features**: Try online search, knowledge base, prompt engineering
3. **Customize settings**: Adjust model parameters
4. **Try different models**: `ollama pull mistral` or `ollama pull codellama`

---

## 🎓 Learning Path

**Beginner (Day 1):**
- Basic chat
- Example prompts
- Model selection

**Intermediate (Week 1):**
- Upload documents
- Use knowledge base
- Try prompt enhancement

**Advanced (Month 1):**
- Online search integration
- Custom model parameters
- Programmatic API use

---

## 💡 Pro Tips

1. **Use Shift+Enter** for new lines without sending
2. **Click "Copy Last"** to copy AI responses
3. **Use "Re-ask"** to easily repeat questions
4. **Export chat** to save conversations
5. **Try different models** for different tasks

---

## 🔗 Quick Links

- **Full README**: [README.md](README.md)
- **Installation Guide**: [INSTALL.md](INSTALL.md)
- **Ollama Models**: [ollama.ai/library](https://ollama.ai/library)
- **Get Help**: Open an issue on GitHub

---

## ✅ Verification Checklist

Before using ALAQUER, make sure:

- [ ] Ollama is running (`ollama serve`)
- [ ] At least one model is installed (`ollama list`)
- [ ] R version >= 4.0.0 (`R.version.string`)
- [ ] ALAQUER launched without errors

---

## 🎮 Try These First Prompts

Copy and paste these to get started:

**General:**
```
Explain quantum computing to a 10-year-old
```

**Data Analysis:**
```
What are the key steps in exploratory data analysis?
```

**Code:**
```
Write a Python function to calculate Fibonacci numbers
```

**Creative:**
```
Write a short story about a robot learning to paint
```

**Business:**
```
What are the key elements of a successful product launch?
```

---

## 🚨 Emergency Commands

If something goes wrong:

```r
# Stop everything
q("no")

# Restart R and retry
source("path/to/ALAQUER/install_and_test.R")
```

```bash
# Restart Ollama
pkill ollama
ollama serve
```

---

## ⏱️ Time Estimates

- **First installation**: 5-10 minutes
- **Subsequent launches**: 30 seconds
- **Typical response time**: 5-30 seconds (depends on model and prompt)
- **Document processing**: 10 seconds - 2 minutes (depends on size)

---

## 📊 Model Comparison

| Model | Size | Speed | Best For |
|-------|------|-------|----------|
| phi | 1.6GB | ⚡⚡⚡ | Quick questions |
| mistral | 4GB | ⚡⚡ | General use |
| llama2 | 4GB | ⚡⚡ | Balanced |
| codellama | 7GB | ⚡ | Programming |
| llama3 | 4GB | ⚡⚡ | Latest features |

---

**That's it! You're ready to go! 🚀**

For detailed documentation, see [README.md](README.md)

---

<div align="center">

**Questions?** Check the [Troubleshooting Section](INSTALL.md#troubleshooting)

**Need help?** Open an [Issue on GitHub](https://github.com/yourusername/ALAQUER/issues)

</div>

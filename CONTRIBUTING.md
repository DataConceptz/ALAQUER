# Contributing to ALAQUER

Thank you for your interest in contributing to ALAQUER! This document provides guidelines and instructions for contributing.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Submitting Changes](#submitting-changes)
- [Testing](#testing)
- [Documentation](#documentation)

---

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and beginners
- Focus on constructive feedback
- Respect differing viewpoints
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discriminatory language
- Personal attacks or trolling
- Publishing others' private information
- Other unprofessional conduct

---

## How Can I Contribute?

### 🐛 Reporting Bugs

**Before submitting a bug report:**
- Check existing issues to avoid duplicates
- Verify the bug with the latest version
- Collect relevant information

**Bug Report Template:**

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What you expected to happen

## Actual Behavior
What actually happened

## Environment
- R Version:
- OS:
- Ollama Version:
- ALAQUER Version:

## Error Messages
```
Paste error messages here
```

## Screenshots
If applicable
```

### 💡 Suggesting Enhancements

**Enhancement Suggestion Template:**

```markdown
## Feature Description
Clear description of the proposed feature

## Motivation
Why this feature would be useful

## Proposed Solution
How you think it should work

## Alternatives Considered
Other approaches you've thought about

## Additional Context
Any other relevant information
```

### 📝 Adding Example Prompts

We're always looking for high-quality example prompts!

**Requirements:**
- Professional and clear
- Specific and actionable
- Follows best practices
- Appropriate category

**How to add:**

1. Edit `R/example_prompts.R`
2. Find appropriate category
3. Add your prompt to the list
4. Ensure proper formatting
5. Submit pull request

**Example:**

```r
data_analysis = list(
  name = "Data Analysis",
  prompts = c(
    "Your new professional prompt here...",
    # ... existing prompts
  )
)
```

### 🔧 Contributing Code

See [Development Setup](#development-setup) below.

### 📚 Improving Documentation

Documentation improvements are always welcome:
- Fix typos or unclear sections
- Add examples
- Improve explanations
- Translate to other languages

---

## Development Setup

### Prerequisites

- R >= 4.0.0
- Git
- Ollama installed and running
- Familiarity with R and Shiny

### Initial Setup

```bash
# 1. Fork the repository on GitHub

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/ALAQUER.git
cd ALAQUER

# 3. Add upstream remote
git remote add upstream https://github.com/original/ALAQUER.git

# 4. Create a development branch
git checkout -b feature/your-feature-name
```

### Install Development Dependencies

```r
# In R console
setwd("path/to/ALAQUER")

# Install all dependencies
source("install_and_test.R")

# Install development packages
install.packages(c("devtools", "roxygen2", "testthat", "lintr"))
```

### Project Structure

```
ALAQUER/
├── R/                          # R source code
│   ├── ollama_integration.R    # Ollama API functions
│   ├── knowledge_base.R        # RAG implementation
│   ├── prompt_engineering.R    # Prompt enhancement
│   ├── online_search.R         # Web search
│   ├── response_processing.R   # Response formatting
│   ├── example_prompts.R       # Prompt library
│   ├── ui_module.R            # Shiny UI
│   ├── server_module.R        # Shiny server
│   ├── launch_app.R           # App launcher
│   └── utils.R                # Utilities
├── man/                        # Documentation
├── tests/                      # Tests
├── inst/                       # Installed files
├── DESCRIPTION                 # Package metadata
├── NAMESPACE                   # Exported functions
├── README.md                   # Main documentation
├── INSTALL.md                  # Installation guide
├── CONTRIBUTING.md             # This file
└── LICENSE                     # MIT License
```

---

## Coding Standards

### R Style Guide

Follow the [Tidyverse Style Guide](https://style.tidyverse.org/):

**Naming Conventions:**
```r
# Functions: snake_case
my_function <- function() { }

# Variables: snake_case
user_input <- "text"

# Constants: SCREAMING_SNAKE_CASE
MAX_TOKENS <- 2000
```

**Code Formatting:**
```r
# Good
result <- my_function(
  param1 = value1,
  param2 = value2
)

# Bad
result<-my_function(param1=value1,param2=value2)
```

**Comments:**
```r
# Use comments to explain WHY, not WHAT

# Bad: increment counter
counter <- counter + 1

# Good: Track number of failed attempts for retry logic
counter <- counter + 1
```

### Documentation

Use roxygen2 for function documentation:

```r
#' Function Title
#'
#' Detailed description of what the function does
#'
#' @param param1 Description of parameter 1
#' @param param2 Description of parameter 2
#' @return Description of return value
#' @export
#' @examples
#' \dontrun{
#' my_function(param1 = "value")
#' }
my_function <- function(param1, param2) {
  # Function implementation
}
```

### Error Handling

Always include proper error handling:

```r
# Good
result <- tryCatch({
  risky_operation()
}, error = function(e) {
  warning(paste("Operation failed:", e$message))
  return(NULL)
})

# Bad
result <- risky_operation()  # No error handling
```

### Code Quality

Before submitting:

```r
# Check code style
lintr::lint_package()

# Generate documentation
devtools::document()

# Check package
devtools::check()
```

---

## Submitting Changes

### Workflow

1. **Create a branch:**
   ```bash
   git checkout -b feature/descriptive-name
   ```

2. **Make changes:**
   - Write code
   - Add tests
   - Update documentation

3. **Test thoroughly:**
   ```r
   source("install_and_test.R")
   ```

4. **Commit changes:**
   ```bash
   git add .
   git commit -m "Add feature: descriptive message"
   ```

5. **Push to your fork:**
   ```bash
   git push origin feature/descriptive-name
   ```

6. **Create Pull Request:**
   - Go to GitHub
   - Click "New Pull Request"
   - Fill in template
   - Submit

### Commit Messages

Follow conventional commits format:

```
type(scope): subject

body

footer
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Maintenance

**Examples:**

```bash
feat(prompts): add 10 new business strategy prompts

Added professional prompts for market analysis,
competitive strategy, and business planning.

Closes #123
```

```bash
fix(ollama): handle connection timeout gracefully

Previously crashed on timeout. Now returns
informative error message and retry suggestion.

Fixes #456
```

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Testing
- [ ] Tested locally
- [ ] Added/updated tests
- [ ] All tests pass

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex code
- [ ] Updated documentation
- [ ] No new warnings

## Related Issues
Closes #issue_number
```

---

## Testing

### Running Tests

```r
# Run all tests
devtools::test()

# Run specific test file
testthat::test_file("tests/testthat/test-ollama.R")
```

### Writing Tests

Create test files in `tests/testthat/`:

```r
# tests/testthat/test-ollama.R

test_that("Ollama connection check works", {
  # Mock connection
  result <- check_ollama_connection("http://localhost:11434")

  expect_type(result, "logical")
})

test_that("Ollama query handles errors", {
  # Test with invalid host
  result <- ollama_query(
    prompt = "test",
    model = "llama2",
    host = "http://invalid:9999"
  )

  expect_null(result)
})
```

### Manual Testing

Before submitting:

1. **Launch application:**
   ```r
   launch_alaquer()
   ```

2. **Test affected features:**
   - Send queries
   - Upload documents
   - Try different settings

3. **Check for regressions:**
   - Ensure existing features still work
   - Test edge cases

---

## Documentation

### Updating Documentation

**When adding/changing functions:**
1. Update roxygen2 comments
2. Run `devtools::document()`
3. Update relevant .md files

**When adding features:**
1. Update README.md
2. Add to INSTALL.md if needed
3. Update QUICKSTART.md
4. Add examples

### Documentation Standards

- Clear and concise
- Include examples
- Explain parameters
- Document edge cases
- Update table of contents

---

## Review Process

### What We Look For

1. **Code Quality:**
   - Follows style guide
   - Well-commented
   - No unnecessary complexity

2. **Functionality:**
   - Works as described
   - Handles errors gracefully
   - No breaking changes

3. **Tests:**
   - Adequate test coverage
   - Edge cases covered
   - All tests pass

4. **Documentation:**
   - Functions documented
   - README updated if needed
   - Examples included

### Review Timeline

- Initial review: 2-7 days
- Response to feedback: As needed
- Final approval: 1-3 days after changes

### After Approval

Once approved:
1. Squash commits if requested
2. Maintainer will merge
3. Your contribution will be credited
4. Thank you! 🎉

---

## Recognition

Contributors are recognized in:
- GitHub contributors page
- Release notes
- README acknowledgments

---

## Questions?

- **General questions**: Open a [Discussion](https://github.com/yourusername/ALAQUER/discussions)
- **Bug reports**: Open an [Issue](https://github.com/yourusername/ALAQUER/issues)
- **Security issues**: Email maintainers directly

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## Getting Help

New to contributing? Check these resources:
- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [R Packages Book](https://r-pkgs.org/)
- [Tidyverse Style Guide](https://style.tidyverse.org/)

---

**Thank you for contributing to ALAQUER! 🚀**

Your contributions help make AI more accessible to the R community.

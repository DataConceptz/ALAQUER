\name{ALAQUER-package}
\alias{ALAQUER-package}
\alias{ALAQUER}
\docType{package}
\title{
  Advanced Language AI Query User Experience in R
}
\description{
  ALAQUER is a cutting-edge R package that provides a sophisticated ChatGPT-style
  Shiny interface for interacting with Ollama language models. Enhanced with Super RAG,
  Online Search Integration, AI-Powered Prompt Engineering, and Advanced Response
  Processing for the ultimate AI experience in R.
}
\details{
  \tabular{ll}{
    Package: \tab ALAQUER\cr
    Type: \tab Package\cr
    Version: \tab 1.0.0\cr
    License: \tab MIT + file LICENSE\cr
  }

  \strong{Main Features:}
  \itemize{
    \item \strong{ChatGPT-Style Interface}: Professional, intuitive UI with sidebar controls
    \item \strong{Super RAG}: Enhanced knowledge base with semantic chunking and hybrid search
    \item \strong{AI Prompt Engineering}: Transform basic keywords into optimized prompts
    \item \strong{Example Prompts}: 150+ professional prompts across 10 categories
    \item \strong{Online Search}: DuckDuckGo and Wikipedia integration
    \item \strong{Response Processing}: Intelligent formatting and code enhancement
    \item \strong{Document Support}: TXT, PDF, CSV, Excel, Markdown
  }

  \strong{Quick Start:}
  \enumerate{
    \item Install and start Ollama: \code{ollama serve}
    \item Pull a model: \code{ollama pull llama2}
    \item Launch ALAQUER: \code{launch_alaquer()}
  }
}
\author{
  ALAQUER Developers

  Maintainer: ALAQUER Developer <alaquer@example.com>
}
\references{
  Ollama: \url{https://ollama.ai/}
}
\keyword{ package }
\seealso{
  \code{\link{launch_alaquer}}
}
\examples{
\dontrun{
# Check if system is ready
check_alaquer_ready()

# Install dependencies
install_alaquer_dependencies()

# Launch the application
launch_alaquer()
}
}

\name{launch_alaquer}
\alias{launch_alaquer}
\title{Launch ALAQUER Application}
\usage{
launch_alaquer(
  host = "127.0.0.1",
  port = NULL,
  launch.browser = TRUE,
  ollama_host = "http://localhost:11434"
)
}
\arguments{
\item{host}{Character string. Host to run on (default: "127.0.0.1")}

\item{port}{Integer. Port to run on (default: NULL, will choose automatically)}

\item{launch.browser}{Logical. Whether to launch browser automatically (default: TRUE)}

\item{ollama_host}{Character string. Ollama host URL (default: "http://localhost:11434")}
}
\value{
None. Starts the Shiny application
}
\description{
Launch the main ALAQUER Shiny application with ChatGPT-style interface
for interacting with Ollama language models.
}
\details{
ALAQUER provides a comprehensive AI assistant interface with features including:
\itemize{
  \item ChatGPT-style chat interface
  \item Super RAG with semantic chunking
  \item AI-powered prompt engineering
  \item Online search integration
  \item 150+ professional example prompts
  \item Advanced response processing
}

Before launching, ensure Ollama is running and at least one model is installed.
}
\examples{
\dontrun{
# Launch with default settings
launch_alaquer()

# Launch with custom configuration
launch_alaquer(
  port = 3838,
  ollama_host = "http://localhost:11434"
)
}
}
\seealso{
\code{\link{check_alaquer_ready}}, \code{\link{install_alaquer_dependencies}}
}

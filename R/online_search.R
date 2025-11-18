#' Search DuckDuckGo
#'
#' Perform web search using DuckDuckGo HTML interface
#'
#' @param query Character string. Search query
#' @param max_results Integer. Maximum results to return (default: 5)
#' @param domains Character vector. Specific domains to search (optional)
#' @return Data frame with search results
#' @importFrom rvest read_html html_nodes html_text html_attr
#' @importFrom xml2 read_html
search_duckduckgo <- function(query, max_results = 5, domains = NULL) {
  tryCatch({
    # Build search URL
    search_query <- utils::URLencode(query)

    # Add domain filter if specified
    if (!is.null(domains) && length(domains) > 0) {
      domain_filter <- paste0(" site:", domains, collapse = " OR")
      search_query <- utils::URLencode(paste0(query, domain_filter))
    }

    url <- paste0("https://html.duckduckgo.com/html/?q=", search_query)

    # Read HTML
    webpage <- tryCatch({
      xml2::read_html(url)
    }, error = function(e) {
      warning("Failed to connect to DuckDuckGo")
      return(NULL)
    })

    if (is.null(webpage)) {
      return(data.frame())
    }

    # Extract results
    results <- list()

    # Try to extract result links
    links <- rvest::html_nodes(webpage, ".result__a")
    snippets <- rvest::html_nodes(webpage, ".result__snippet")

    if (length(links) > 0) {
      for (i in seq_len(min(length(links), max_results))) {
        title <- rvest::html_text(links[i])
        link <- rvest::html_attr(links[i], "href")

        snippet <- ""
        if (i <= length(snippets)) {
          snippet <- rvest::html_text(snippets[i])
        }

        results[[i]] <- list(
          title = trimws(title),
          url = link,
          snippet = trimws(snippet),
          source = "DuckDuckGo"
        )
      }
    }

    if (length(results) == 0) {
      return(data.frame())
    }

    # Convert to data frame
    results_df <- do.call(rbind, lapply(results, function(r) {
      data.frame(
        title = r$title,
        url = r$url,
        snippet = r$snippet,
        source = r$source,
        stringsAsFactors = FALSE
      )
    }))

    return(results_df)

  }, error = function(e) {
    warning(paste("Error searching DuckDuckGo:", e$message))
    return(data.frame())
  })
}

#' Search Wikipedia
#'
#' Search Wikipedia and retrieve article summaries
#'
#' @param query Character string. Search query
#' @param max_results Integer. Maximum results to return (default: 3)
#' @return Data frame with Wikipedia results
search_wikipedia <- function(query, max_results = 3) {
  tryCatch({
    # Wikipedia API search endpoint
    search_url <- paste0(
      "https://en.wikipedia.org/w/api.php?",
      "action=opensearch&",
      "format=json&",
      "search=", utils::URLencode(query),
      "&limit=", max_results
    )

    # Perform search
    response <- httr::GET(search_url)

    if (httr::status_code(response) != 200) {
      warning("Failed to connect to Wikipedia")
      return(data.frame())
    }

    content <- httr::content(response, as = "parsed")

    if (length(content) < 4 || length(content[[2]]) == 0) {
      return(data.frame())
    }

    titles <- content[[2]]
    descriptions <- content[[3]]
    urls <- content[[4]]

    results <- list()

    for (i in seq_along(titles)) {
      results[[i]] <- list(
        title = titles[[i]],
        snippet = descriptions[[i]],
        url = urls[[i]],
        source = "Wikipedia"
      )
    }

    # Convert to data frame
    results_df <- do.call(rbind, lapply(results, function(r) {
      data.frame(
        title = r$title,
        url = r$url,
        snippet = r$snippet,
        source = r$source,
        stringsAsFactors = FALSE
      )
    }))

    return(results_df)

  }, error = function(e) {
    warning(paste("Error searching Wikipedia:", e$message))
    return(data.frame())
  })
}

#' Get Wikipedia Article Content
#'
#' Retrieve full content of a Wikipedia article
#'
#' @param title Character string. Article title
#' @return Character string with article content
get_wikipedia_content <- function(title) {
  tryCatch({
    # Wikipedia API content endpoint
    content_url <- paste0(
      "https://en.wikipedia.org/w/api.php?",
      "action=query&",
      "format=json&",
      "prop=extracts&",
      "exintro=1&",
      "explaintext=1&",
      "titles=", utils::URLencode(title)
    )

    response <- httr::GET(content_url)

    if (httr::status_code(response) != 200) {
      return(NULL)
    }

    content <- httr::content(response, as = "parsed")

    pages <- content$query$pages

    if (length(pages) == 0) {
      return(NULL)
    }

    page <- pages[[1]]

    if (!is.null(page$extract)) {
      return(page$extract)
    }

    return(NULL)

  }, error = function(e) {
    warning(paste("Error fetching Wikipedia content:", e$message))
    return(NULL)
  })
}

#' Fetch and Summarize URL Content
#'
#' Fetch content from a URL and extract main text
#'
#' @param url Character string. URL to fetch
#' @param max_chars Integer. Maximum characters to return (default: 2000)
#' @return Character string with extracted text
fetch_url_content <- function(url, max_chars = 2000) {
  tryCatch({
    webpage <- xml2::read_html(url)

    # Try to extract main content
    # Look for common content containers
    content <- rvest::html_nodes(webpage, "article, main, .content, .main-content, #content")

    if (length(content) == 0) {
      # Fallback to body paragraphs
      content <- rvest::html_nodes(webpage, "p")
    }

    text <- rvest::html_text(content)
    text <- paste(text, collapse = " ")

    # Clean up text
    text <- gsub("\\s+", " ", text)
    text <- trimws(text)

    # Truncate if too long
    if (nchar(text) > max_chars) {
      text <- substr(text, 1, max_chars)
      text <- paste0(text, "...")
    }

    return(text)

  }, error = function(e) {
    warning(paste("Error fetching URL content:", e$message))
    return(NULL)
  })
}

#' Perform Online Search
#'
#' Unified interface for online search (DuckDuckGo + Wikipedia)
#'
#' @param query Character string. Search query
#' @param sources Character vector. Sources to search: "duckduckgo", "wikipedia" (default: both)
#' @param max_results Integer. Maximum results per source (default: 3)
#' @param domains Character vector. Specific domains to search on DuckDuckGo (optional)
#' @param fetch_content Logical. Whether to fetch full content from URLs (default: FALSE)
#' @return Data frame with combined search results
#' @export
#' @examples
#' \dontrun{
#' results <- search_online("machine learning", sources = c("duckduckgo", "wikipedia"))
#' }
search_online <- function(query,
                         sources = c("duckduckgo", "wikipedia"),
                         max_results = 3,
                         domains = NULL,
                         fetch_content = FALSE) {

  all_results <- list()

  # Search DuckDuckGo
  if ("duckduckgo" %in% sources) {
    ddg_results <- search_duckduckgo(query, max_results, domains)
    if (nrow(ddg_results) > 0) {
      all_results <- c(all_results, list(ddg_results))
    }
  }

  # Search Wikipedia
  if ("wikipedia" %in% sources) {
    wiki_results <- search_wikipedia(query, max_results)
    if (nrow(wiki_results) > 0) {
      all_results <- c(all_results, list(wiki_results))
    }
  }

  if (length(all_results) == 0) {
    return(data.frame())
  }

  # Combine results
  combined_results <- do.call(rbind, all_results)

  # Optionally fetch full content
  if (fetch_content && nrow(combined_results) > 0) {
    combined_results$content <- sapply(combined_results$url, function(url) {
      content <- fetch_url_content(url)
      if (is.null(content)) "" else content
    })
  }

  # Calculate relevance scores
  combined_results$relevance_score <- calculate_relevance_score(
    combined_results$title,
    combined_results$snippet,
    query
  )

  # Sort by relevance
  combined_results <- combined_results[order(-combined_results$relevance_score), ]

  return(combined_results)
}

#' Calculate Relevance Score
#'
#' Calculate relevance score for search results
#'
#' @param titles Character vector. Result titles
#' @param snippets Character vector. Result snippets
#' @param query Character string. Search query
#' @return Numeric vector of relevance scores
calculate_relevance_score <- function(titles, snippets, query) {
  query_words <- tolower(unlist(strsplit(query, "\\s+")))

  scores <- numeric(length(titles))

  for (i in seq_along(titles)) {
    title_lower <- tolower(titles[i])
    snippet_lower <- tolower(snippets[i])

    # Count query word matches in title (weighted more)
    title_matches <- sum(sapply(query_words, function(w) {
      stringr::str_count(title_lower, w)
    })) * 2

    # Count query word matches in snippet
    snippet_matches <- sum(sapply(query_words, function(w) {
      stringr::str_count(snippet_lower, w)
    }))

    scores[i] <- title_matches + snippet_matches
  }

  # Normalize scores to 0-1 range
  if (max(scores) > 0) {
    scores <- scores / max(scores)
  }

  return(scores)
}

#' Format Search Results for AI Context
#'
#' Format online search results for inclusion in AI prompts
#'
#' @param results Data frame. Search results from search_online()
#' @param max_results Integer. Maximum results to include (default: 5)
#' @return Character string with formatted search context
#' @export
format_search_context <- function(results, max_results = 5) {
  if (nrow(results) == 0) {
    return("")
  }

  results <- head(results, max_results)

  context_parts <- lapply(1:nrow(results), function(i) {
    paste0(
      i, ". ", results$title[i], "\n",
      "   Source: ", results$source[i], "\n",
      "   URL: ", results$url[i], "\n",
      "   Summary: ", results$snippet[i], "\n",
      "   Relevance: ", round(results$relevance_score[i], 2)
    )
  })

  context <- paste0(
    "Online search results for your query:\n\n",
    paste(context_parts, collapse = "\n\n")
  )

  return(context)
}

#' Summarize Search Results
#'
#' Create a concise summary of search results
#'
#' @param results Data frame. Search results
#' @return Character string with summary
#' @export
summarize_search_results <- function(results) {
  if (nrow(results) == 0) {
    return("No search results found.")
  }

  summary <- paste0(
    "Found ", nrow(results), " results from ",
    length(unique(results$source)), " source(s).\n\n",
    "Top results:\n",
    paste(lapply(1:min(3, nrow(results)), function(i) {
      paste0("- ", results$title[i], " (", results$source[i], ")")
    }), collapse = "\n")
  )

  return(summary)
}

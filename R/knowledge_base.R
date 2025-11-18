#' Extract Text from PDF
#'
#' Extract text content from a PDF file
#'
#' @param file_path Character string. Path to PDF file
#' @return Character string with extracted text, or NULL if error
#' @importFrom pdftools pdf_text
extract_pdf_text <- function(file_path) {
  tryCatch({
    text <- pdftools::pdf_text(file_path)
    return(paste(text, collapse = "\n"))
  }, error = function(e) {
    warning(paste("Error reading PDF:", e$message))
    return(NULL)
  })
}

#' Extract Text from Document
#'
#' Extract text from various document formats
#'
#' @param file_path Character string. Path to document file
#' @return Character string with extracted text, or NULL if error
extract_document_text <- function(file_path) {
  ext <- tolower(tools::file_ext(file_path))

  text <- tryCatch({
    switch(ext,
      "txt" = readr::read_file(file_path),
      "pdf" = extract_pdf_text(file_path),
      "csv" = {
        data <- readr::read_csv(file_path, show_col_types = FALSE)
        paste(capture.output(print(data)), collapse = "\n")
      },
      "xlsx" = {
        data <- readxl::read_excel(file_path)
        paste(capture.output(print(data)), collapse = "\n")
      },
      "xls" = {
        data <- readxl::read_excel(file_path)
        paste(capture.output(print(data)), collapse = "\n")
      },
      "md" = readr::read_file(file_path),
      "rmd" = readr::read_file(file_path),
      NULL
    )
  }, error = function(e) {
    warning(paste("Error reading file:", file_path, "-", e$message))
    return(NULL)
  })

  return(text)
}

#' Semantic Text Chunking
#'
#' Split text into semantic chunks with intelligent overlap
#'
#' @param text Character string. Text to chunk
#' @param chunk_size Integer. Target size for each chunk (default: 500)
#' @param overlap Integer. Number of overlapping characters (default: 100)
#' @return List of text chunks
semantic_chunking <- function(text, chunk_size = 500, overlap = 100) {
  # Split into sentences
  sentences <- unlist(strsplit(text, "(?<=[.!?])\\s+", perl = TRUE))

  chunks <- list()
  current_chunk <- ""
  current_size <- 0

  for (sentence in sentences) {
    sentence_size <- nchar(sentence)

    if (current_size + sentence_size > chunk_size && current_size > 0) {
      # Save current chunk
      chunks[[length(chunks) + 1]] <- current_chunk

      # Start new chunk with overlap
      if (overlap > 0) {
        # Get last part of current chunk for overlap
        overlap_text <- substr(current_chunk,
                              max(1, nchar(current_chunk) - overlap),
                              nchar(current_chunk))
        current_chunk <- paste(overlap_text, sentence)
        current_size <- nchar(current_chunk)
      } else {
        current_chunk <- sentence
        current_size <- sentence_size
      }
    } else {
      # Add sentence to current chunk
      if (current_size > 0) {
        current_chunk <- paste(current_chunk, sentence)
      } else {
        current_chunk <- sentence
      }
      current_size <- nchar(current_chunk)
    }
  }

  # Add last chunk
  if (current_size > 0) {
    chunks[[length(chunks) + 1]] <- current_chunk
  }

  return(chunks)
}

#' Extract Keywords from Text
#'
#' Extract important keywords using TF-IDF
#'
#' @param text Character string. Text to analyze
#' @param max_keywords Integer. Maximum number of keywords (default: 10)
#' @return Character vector of keywords
extract_keywords <- function(text, max_keywords = 10) {
  tryCatch({
    # Create corpus
    corpus <- tm::Corpus(tm::VectorSource(text))

    # Clean text
    corpus <- tm::tm_map(corpus, tm::content_transformer(tolower))
    corpus <- tm::tm_map(corpus, tm::removePunctuation)
    corpus <- tm::tm_map(corpus, tm::removeNumbers)
    corpus <- tm::tm_map(corpus, tm::removeWords, tm::stopwords("english"))
    corpus <- tm::tm_map(corpus, tm::stripWhitespace)

    # Create TDM
    tdm <- tm::TermDocumentMatrix(corpus)
    m <- as.matrix(tdm)
    word_freqs <- sort(rowSums(m), decreasing = TRUE)

    # Get top keywords
    keywords <- names(head(word_freqs, max_keywords))
    return(keywords)

  }, error = function(e) {
    warning(paste("Error extracting keywords:", e$message))
    return(character(0))
  })
}

#' Extract Named Entities
#'
#' Simple entity extraction (names, dates, numbers)
#'
#' @param text Character string. Text to analyze
#' @return List with entities by type
extract_entities <- function(text) {
  entities <- list(
    dates = stringr::str_extract_all(text, "\\d{1,2}/\\d{1,2}/\\d{2,4}|\\d{4}-\\d{2}-\\d{2}")[[1]],
    numbers = stringr::str_extract_all(text, "\\b\\d+(\\.\\d+)?\\b")[[1]],
    capitalized = stringr::str_extract_all(text, "\\b[A-Z][a-z]+\\b")[[1]]
  )

  return(entities)
}

#' Classify Document Type
#'
#' Simple document classification based on content
#'
#' @param text Character string. Text to classify
#' @return Character string with document type
classify_document <- function(text) {
  text_lower <- tolower(text)

  if (stringr::str_detect(text_lower, "abstract|introduction|methodology|results|conclusion")) {
    return("academic")
  } else if (stringr::str_detect(text_lower, "function|class|import|return|def|var|const")) {
    return("code")
  } else if (stringr::str_detect(text_lower, "revenue|profit|sales|market|business")) {
    return("business")
  } else if (stringr::str_detect(text_lower, "patient|medical|diagnosis|treatment|symptoms")) {
    return("medical")
  } else {
    return("general")
  }
}

#' Create Knowledge Base with Super RAG
#'
#' Create an enhanced knowledge base from document files
#'
#' @param file_paths Character vector. Paths to document files
#' @param kb_name Character string. Name for the knowledge base (default: "default")
#' @param chunk_size Integer. Target chunk size (default: 500)
#' @param overlap Integer. Chunk overlap size (default: 100)
#' @return List containing knowledge base data
#' @export
#' @examples
#' \dontrun{
#' kb <- create_knowledge_base(
#'   file_paths = c("doc1.pdf", "doc2.txt"),
#'   kb_name = "my_kb"
#' )
#' }
create_knowledge_base <- function(file_paths, kb_name = "default",
                                  chunk_size = 500, overlap = 100) {
  kb <- list(
    name = kb_name,
    created = Sys.time(),
    documents = list(),
    chunks = list(),
    metadata = list()
  )

  for (file_path in file_paths) {
    if (!file.exists(file_path)) {
      warning(paste("File not found:", file_path))
      next
    }

    message(paste("Processing:", basename(file_path)))

    # Extract text
    text <- extract_document_text(file_path)

    if (is.null(text) || nchar(text) == 0) {
      warning(paste("No text extracted from:", file_path))
      next
    }

    # Create semantic chunks
    chunks <- semantic_chunking(text, chunk_size, overlap)

    # Extract metadata
    keywords <- extract_keywords(text, max_keywords = 15)
    entities <- extract_entities(text)
    doc_type <- classify_document(text)

    # Store document
    doc_id <- digest::digest(file_path)
    kb$documents[[doc_id]] <- list(
      path = file_path,
      name = basename(file_path),
      text = text,
      doc_type = doc_type,
      keywords = keywords,
      entities = entities,
      chunk_count = length(chunks),
      processed = Sys.time()
    )

    # Store chunks with metadata
    for (i in seq_along(chunks)) {
      chunk_id <- paste0(doc_id, "_chunk_", i)
      chunk_keywords <- extract_keywords(chunks[[i]], max_keywords = 5)

      kb$chunks[[chunk_id]] <- list(
        text = chunks[[i]],
        doc_id = doc_id,
        chunk_index = i,
        keywords = chunk_keywords,
        size = nchar(chunks[[i]])
      )
    }
  }

  if (length(kb$documents) == 0) {
    warning("No valid documents could be processed")
    return(NULL)
  }

  kb$metadata <- list(
    total_documents = length(kb$documents),
    total_chunks = length(kb$chunks),
    avg_chunk_size = mean(sapply(kb$chunks, function(c) c$size))
  )

  message(paste("Knowledge base created:",
               kb$metadata$total_documents, "documents,",
               kb$metadata$total_chunks, "chunks"))

  return(kb)
}

#' Hybrid Search in Knowledge Base
#'
#' Search using keyword, entity, and semantic matching
#'
#' @param kb List. Knowledge base object
#' @param query Character string. Search query
#' @param max_results Integer. Maximum results to return (default: 5)
#' @param min_score Numeric. Minimum relevance score (default: 0.1)
#' @return Data frame with search results
#' @export
#' @examples
#' \dontrun{
#' results <- search_knowledge_base(kb, "machine learning", max_results = 5)
#' }
search_knowledge_base <- function(kb, query, max_results = 5, min_score = 0.1) {
  if (is.null(kb) || length(kb$chunks) == 0) {
    return(data.frame())
  }

  query_lower <- tolower(query)
  query_words <- unlist(strsplit(query_lower, "\\s+"))

  results <- list()

  for (chunk_id in names(kb$chunks)) {
    chunk <- kb$chunks[[chunk_id]]
    chunk_text_lower <- tolower(chunk$text)

    # Keyword matching score
    keyword_score <- sum(sapply(query_words, function(word) {
      stringr::str_count(chunk_text_lower, word)
    })) / max(1, length(query_words))

    # Entity matching score
    entity_score <- sum(chunk$keywords %in% query_words) / max(1, length(chunk$keywords))

    # Semantic similarity (simple word overlap)
    chunk_words <- unique(unlist(strsplit(chunk_text_lower, "\\s+")))
    semantic_score <- length(intersect(query_words, chunk_words)) / max(1, length(union(query_words, chunk_words)))

    # Combined score with weights
    combined_score <- (keyword_score * 0.5) + (entity_score * 0.3) + (semantic_score * 0.2)

    if (combined_score >= min_score) {
      doc <- kb$documents[[chunk$doc_id]]

      results[[length(results) + 1]] <- list(
        chunk_id = chunk_id,
        text = chunk$text,
        score = combined_score,
        doc_name = doc$name,
        doc_type = doc$doc_type,
        chunk_index = chunk$chunk_index
      )
    }
  }

  if (length(results) == 0) {
    return(data.frame())
  }

  # Convert to data frame and sort by score
  results_df <- do.call(rbind, lapply(results, function(r) {
    data.frame(
      chunk_id = r$chunk_id,
      text = r$text,
      score = r$score,
      doc_name = r$doc_name,
      doc_type = r$doc_type,
      chunk_index = r$chunk_index,
      stringsAsFactors = FALSE
    )
  }))

  results_df <- results_df[order(-results_df$score), ]
  results_df <- head(results_df, max_results)

  return(results_df)
}

#' Get Knowledge Base Context
#'
#' Get relevant context from knowledge base for a query
#'
#' @param kb List. Knowledge base object
#' @param query Character string. User query
#' @param max_context Integer. Maximum context chunks (default: 3)
#' @return Character string with formatted context
#' @export
get_kb_context <- function(kb, query, max_context = 3) {
  if (is.null(kb)) {
    return("")
  }

  results <- search_knowledge_base(kb, query, max_results = max_context)

  if (nrow(results) == 0) {
    return("")
  }

  context_parts <- lapply(1:nrow(results), function(i) {
    paste0("Source: ", results$doc_name[i],
          " (Score: ", round(results$score[i], 2), ")\n",
          results$text[i])
  })

  context <- paste0(
    "Relevant information from knowledge base:\n\n",
    paste(context_parts, collapse = "\n\n---\n\n")
  )

  return(context)
}

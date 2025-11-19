#' Advanced RAG System
#'
#' Enhanced Retrieval-Augmented Generation with vector embeddings,
#' semantic search, reranking, and multi-modal knowledge bases.
#'
#' @name advanced_rag
NULL

#' Create Vector Knowledge Base
#'
#' Create an advanced knowledge base with vector embeddings.
#'
#' @param name Knowledge base name
#' @param embedding_model Ollama model for generating embeddings (default: "nomic-embed-text")
#' @param chunk_size Chunk size for document splitting (default: 500)
#' @param chunk_overlap Overlap between chunks (default: 100)
#' @param host Ollama host (default: "http://localhost:11434")
#' @return Vector knowledge base object
#' @export
create_vector_kb <- function(name, embedding_model = "nomic-embed-text",
                             chunk_size = 500, chunk_overlap = 100,
                             host = "http://localhost:11434") {

  kb <- list(
    name = name,
    embedding_model = embedding_model,
    chunk_size = chunk_size,
    chunk_overlap = chunk_overlap,
    host = host,
    documents = list(),
    chunks = list(),
    embeddings = list(),
    metadata = list(),
    created = Sys.time(),
    index = NULL
  )

  class(kb) <- c("alaquer_vector_kb", "list")

  message("Created vector knowledge base: ", name)
  return(kb)
}

#' Generate Embedding
#'
#' Generate vector embedding for text using Ollama.
#'
#' @param text Text to embed
#' @param model Embedding model (default: "nomic-embed-text")
#' @param host Ollama host (default: "http://localhost:11434")
#' @return Embedding vector
#' @export
generate_embedding <- function(text, model = "nomic-embed-text", host = "http://localhost:11434") {
  endpoint <- paste0(host, "/api/embeddings")

  payload <- list(
    model = model,
    prompt = text
  )

  tryCatch({
    response <- httr::POST(
      url = endpoint,
      body = jsonlite::toJSON(payload, auto_unbox = TRUE),
      httr::content_type_json()
    )

    if (httr::status_code(response) == 200) {
      content <- httr::content(response, as = "parsed")
      embedding <- unlist(content$embedding)
      return(embedding)
    } else {
      warning("Failed to generate embedding: HTTP ", httr::status_code(response))
      return(NULL)
    }

  }, error = function(e) {
    warning("Error generating embedding: ", e$message)
    return(NULL)
  })
}

#' Add Document to Vector KB
#'
#' Add a document to the vector knowledge base with automatic chunking and embedding.
#'
#' @param kb Vector knowledge base object
#' @param document_text Document text
#' @param document_id Document identifier
#' @param metadata Additional metadata (optional)
#' @return Updated knowledge base
#' @export
add_document_to_vector_kb <- function(kb, document_text, document_id, metadata = NULL) {
  message("Processing document: ", document_id)

  # Smart chunking with overlap
  chunks <- smart_chunk_text(document_text, kb$chunk_size, kb$chunk_overlap)

  message("Created ", length(chunks), " chunks")

  # Generate embeddings for each chunk
  chunk_data <- list()

  for (i in seq_along(chunks)) {
    if (i %% 10 == 0) {
      message("Processing chunk ", i, "/", length(chunks))
    }

    chunk_text <- chunks[i]

    # Generate embedding
    embedding <- generate_embedding(chunk_text, kb$embedding_model, kb$host)

    if (!is.null(embedding)) {
      chunk_data[[i]] <- list(
        document_id = document_id,
        chunk_id = paste0(document_id, "_chunk_", i),
        text = chunk_text,
        embedding = embedding,
        metadata = metadata
      )
    }
  }

  # Add to knowledge base
  kb$documents[[document_id]] <- document_text
  kb$metadata[[document_id]] <- metadata

  # Append chunks
  start_idx <- length(kb$chunks) + 1
  for (i in seq_along(chunk_data)) {
    kb$chunks[[start_idx + i - 1]] <- chunk_data[[i]]
  }

  # Update embeddings matrix
  kb <- update_embedding_index(kb)

  message("Document added successfully: ", document_id)
  return(kb)
}

#' Smart Text Chunking
#'
#' Intelligent text chunking that respects sentence boundaries.
#'
#' @param text Text to chunk
#' @param chunk_size Target chunk size
#' @param overlap Overlap between chunks
#' @return Vector of chunks
#' @export
smart_chunk_text <- function(text, chunk_size = 500, overlap = 100) {
  # Split into sentences
  sentences <- unlist(strsplit(text, "(?<=[.!?])\\s+", perl = TRUE))

  chunks <- list()
  current_chunk <- ""
  current_size <- 0

  for (sentence in sentences) {
    sentence_size <- nchar(sentence)

    if (current_size + sentence_size > chunk_size && current_size > 0) {
      # Save current chunk
      chunks[[length(chunks) + 1]] <- trimws(current_chunk)

      # Start new chunk with overlap
      words <- unlist(strsplit(current_chunk, "\\s+"))
      overlap_words <- tail(words, min(overlap, length(words)))
      current_chunk <- paste(overlap_words, collapse = " ")
      current_size <- nchar(current_chunk)
    }

    current_chunk <- paste(current_chunk, sentence)
    current_size <- nchar(current_chunk)
  }

  # Add final chunk
  if (nchar(trimws(current_chunk)) > 0) {
    chunks[[length(chunks) + 1]] <- trimws(current_chunk)
  }

  return(unlist(chunks))
}

#' Update Embedding Index
#'
#' Build/update the embedding index for fast similarity search.
#'
#' @param kb Vector knowledge base
#' @return Updated knowledge base
#' @keywords internal
update_embedding_index <- function(kb) {
  if (length(kb$chunks) == 0) {
    return(kb)
  }

  # Extract embeddings into matrix
  embedding_list <- lapply(kb$chunks, function(chunk) chunk$embedding)
  embedding_matrix <- do.call(rbind, embedding_list)

  kb$embeddings <- embedding_matrix

  # Build index for fast search (using simple matrix for now)
  kb$index <- list(
    matrix = embedding_matrix,
    chunk_ids = sapply(kb$chunks, function(c) c$chunk_id),
    updated = Sys.time()
  )

  return(kb)
}

#' Semantic Search
#'
#' Perform semantic search using vector similarity.
#'
#' @param kb Vector knowledge base
#' @param query Query text
#' @param top_k Number of results to return (default: 5)
#' @param min_similarity Minimum similarity threshold (default: 0.5)
#' @return Search results with scores
#' @export
semantic_search <- function(kb, query, top_k = 5, min_similarity = 0.5) {
  if (length(kb$chunks) == 0) {
    warning("Knowledge base is empty")
    return(list())
  }

  message("Performing semantic search...")

  # Generate query embedding
  query_embedding <- generate_embedding(query, kb$embedding_model, kb$host)

  if (is.null(query_embedding)) {
    warning("Failed to generate query embedding")
    return(list())
  }

  # Calculate cosine similarity with all chunks
  similarities <- apply(kb$index$matrix, 1, function(chunk_embedding) {
    cosine_similarity(query_embedding, chunk_embedding)
  })

  # Filter by minimum similarity
  valid_indices <- which(similarities >= min_similarity)

  if (length(valid_indices) == 0) {
    message("No results above similarity threshold")
    return(list())
  }

  # Sort by similarity
  sorted_indices <- valid_indices[order(similarities[valid_indices], decreasing = TRUE)]
  top_indices <- head(sorted_indices, top_k)

  # Build results
  results <- lapply(top_indices, function(idx) {
    chunk <- kb$chunks[[idx]]
    list(
      chunk_id = chunk$chunk_id,
      document_id = chunk$document_id,
      text = chunk$text,
      similarity = similarities[idx],
      metadata = chunk$metadata
    )
  })

  message("Found ", length(results), " results")

  return(results)
}

#' Cosine Similarity
#'
#' Calculate cosine similarity between two vectors.
#'
#' @param v1 Vector 1
#' @param v2 Vector 2
#' @return Similarity score (0-1)
#' @keywords internal
cosine_similarity <- function(v1, v2) {
  dot_product <- sum(v1 * v2)
  magnitude <- sqrt(sum(v1^2)) * sqrt(sum(v2^2))

  if (magnitude == 0) {
    return(0)
  }

  similarity <- dot_product / magnitude
  return(similarity)
}

#' Hybrid Search
#'
#' Combine semantic search with keyword-based search.
#'
#' @param kb Vector knowledge base
#' @param query Query text
#' @param top_k Number of results (default: 5)
#' @param semantic_weight Weight for semantic results (0-1, default: 0.7)
#' @return Hybrid search results
#' @export
hybrid_search <- function(kb, query, top_k = 5, semantic_weight = 0.7) {
  message("Performing hybrid search...")

  # Semantic search
  semantic_results <- semantic_search(kb, query, top_k = top_k * 2, min_similarity = 0.3)

  # Keyword search
  keyword_results <- keyword_search_kb(kb, query, top_k = top_k * 2)

  # Combine and rerank
  all_chunk_ids <- unique(c(
    sapply(semantic_results, function(r) r$chunk_id),
    sapply(keyword_results, function(r) r$chunk_id)
  ))

  # Calculate combined scores
  combined_results <- lapply(all_chunk_ids, function(chunk_id) {
    # Get semantic score
    semantic_match <- Find(function(r) r$chunk_id == chunk_id, semantic_results)
    semantic_score <- if (!is.null(semantic_match)) semantic_match$similarity else 0

    # Get keyword score
    keyword_match <- Find(function(r) r$chunk_id == chunk_id, keyword_results)
    keyword_score <- if (!is.null(keyword_match)) keyword_match$score else 0

    # Combined score
    combined_score <- (semantic_weight * semantic_score) + ((1 - semantic_weight) * keyword_score)

    # Get chunk data
    chunk_idx <- which(sapply(kb$chunks, function(c) c$chunk_id == chunk_id))
    chunk <- kb$chunks[[chunk_idx]]

    list(
      chunk_id = chunk_id,
      document_id = chunk$document_id,
      text = chunk$text,
      score = combined_score,
      semantic_score = semantic_score,
      keyword_score = keyword_score,
      metadata = chunk$metadata
    )
  })

  # Sort by combined score
  combined_results <- combined_results[order(sapply(combined_results, function(r) r$score), decreasing = TRUE)]

  # Return top-k
  results <- head(combined_results, top_k)

  message("Hybrid search complete: ", length(results), " results")

  return(results)
}

#' Keyword Search in KB
#'
#' Perform keyword-based search in knowledge base.
#'
#' @param kb Knowledge base
#' @param query Query text
#' @param top_k Number of results
#' @return Search results with keyword scores
#' @keywords internal
keyword_search_kb <- function(kb, query, top_k = 5) {
  query_terms <- tolower(unlist(strsplit(query, "\\W+")))
  query_terms <- query_terms[nchar(query_terms) > 2]  # Filter short terms

  if (length(query_terms) == 0) {
    return(list())
  }

  # Score each chunk by keyword matching
  scores <- sapply(kb$chunks, function(chunk) {
    text_lower <- tolower(chunk$text)

    # Count matches
    matches <- sum(sapply(query_terms, function(term) {
      grepl(term, text_lower, fixed = TRUE)
    }))

    # Normalize by query length
    score <- matches / length(query_terms)
    return(score)
  })

  # Get top results
  top_indices <- head(order(scores, decreasing = TRUE), top_k)

  results <- lapply(top_indices, function(idx) {
    chunk <- kb$chunks[[idx]]
    list(
      chunk_id = chunk$chunk_id,
      document_id = chunk$document_id,
      text = chunk$text,
      score = scores[idx],
      metadata = chunk$metadata
    )
  })

  # Filter zero scores
  results <- Filter(function(r) r$score > 0, results)

  return(results)
}

#' Rerank Results
#'
#' Rerank search results using cross-encoder or relevance scoring.
#'
#' @param results Search results
#' @param query Original query
#' @param model Ollama model for reranking (default: "llama3.2")
#' @param host Ollama host
#' @return Reranked results
#' @export
rerank_results <- function(results, query, model = "llama3.2", host = "http://localhost:11434") {
  if (length(results) == 0) {
    return(results)
  }

  message("Reranking ", length(results), " results...")

  # Score each result for relevance
  for (i in seq_along(results)) {
    result <- results[[i]]

    # Create relevance prompt
    prompt <- paste0(
      "Rate the relevance of the following text to the query on a scale of 0-10.\n\n",
      "Query: ", query, "\n\n",
      "Text: ", substr(result$text, 1, 500), "\n\n",
      "Relevance score (0-10):"
    )

    # Query model for relevance score
    tryCatch({
      response <- ollama_query(prompt, model, host, temperature = 0.1)

      # Extract numeric score
      score_match <- regmatches(response, regexpr("[0-9]+", response))

      if (length(score_match) > 0) {
        relevance_score <- as.numeric(score_match[1]) / 10
        results[[i]]$rerank_score <- relevance_score
      } else {
        results[[i]]$rerank_score <- result$score
      }

    }, error = function(e) {
      results[[i]]$rerank_score <- result$score
    })
  }

  # Sort by rerank score
  results <- results[order(sapply(results, function(r) r$rerank_score), decreasing = TRUE)]

  message("Reranking complete")

  return(results)
}

#' Query with RAG
#'
#' Query Ollama with RAG-enhanced context from vector knowledge base.
#'
#' @param kb Vector knowledge base
#' @param query User query
#' @param model Ollama model (default: "llama3.2")
#' @param top_k Number of context chunks (default: 3)
#' @param use_hybrid Use hybrid search (default: TRUE)
#' @param use_reranking Use reranking (default: FALSE)
#' @param host Ollama host
#' @return Model response with context
#' @export
query_with_rag <- function(kb, query, model = "llama3.2", top_k = 3,
                           use_hybrid = TRUE, use_reranking = FALSE,
                           host = "http://localhost:11434") {

  message("Querying with RAG...")

  # Retrieve relevant context
  if (use_hybrid) {
    results <- hybrid_search(kb, query, top_k = top_k)
  } else {
    results <- semantic_search(kb, query, top_k = top_k)
  }

  if (length(results) == 0) {
    message("No relevant context found, querying without RAG")
    response <- ollama_query(query, model, host)
    return(list(
      response = response,
      context = NULL,
      context_used = FALSE
    ))
  }

  # Optionally rerank
  if (use_reranking) {
    results <- rerank_results(results, query, model, host)
  }

  # Build context
  context_text <- paste(sapply(results, function(r) {
    paste0("Source: ", r$document_id, "\n", r$text)
  }), collapse = "\n\n---\n\n")

  # Create RAG prompt
  rag_prompt <- paste0(
    "Use the following context to answer the question. ",
    "If the context doesn't contain relevant information, say so.\n\n",
    "Context:\n", context_text, "\n\n",
    "Question: ", query, "\n\n",
    "Answer:"
  )

  # Query model
  response <- ollama_query(rag_prompt, model, host)

  return(list(
    response = response,
    context = results,
    context_used = TRUE,
    num_chunks = length(results)
  ))
}

#' Save Vector KB
#'
#' Save vector knowledge base to disk.
#'
#' @param kb Vector knowledge base
#' @param filepath Output filepath
#' @export
save_vector_kb <- function(kb, filepath) {
  filepath <- path.expand(filepath)

  tryCatch({
    saveRDS(kb, filepath)
    message("Vector knowledge base saved: ", filepath)
    return(TRUE)
  }, error = function(e) {
    warning("Failed to save knowledge base: ", e$message)
    return(FALSE)
  })
}

#' Load Vector KB
#'
#' Load vector knowledge base from disk.
#'
#' @param filepath Input filepath
#' @return Vector knowledge base
#' @export
load_vector_kb <- function(filepath) {
  filepath <- path.expand(filepath)

  if (!file.exists(filepath)) {
    stop("Knowledge base file not found: ", filepath)
  }

  tryCatch({
    kb <- readRDS(filepath)
    message("Vector knowledge base loaded: ", filepath)
    message("Documents: ", length(kb$documents))
    message("Chunks: ", length(kb$chunks))
    return(kb)
  }, error = function(e) {
    stop("Failed to load knowledge base: ", e$message)
  })
}

#' Get KB Statistics
#'
#' Get statistics about the vector knowledge base.
#'
#' @param kb Vector knowledge base
#' @return Statistics list
#' @export
get_kb_statistics <- function(kb) {
  stats <- list(
    name = kb$name,
    documents = length(kb$documents),
    chunks = length(kb$chunks),
    embedding_model = kb$embedding_model,
    chunk_size = kb$chunk_size,
    chunk_overlap = kb$chunk_overlap,
    created = kb$created,
    total_text_size = sum(sapply(kb$documents, nchar)),
    avg_chunk_size = if (length(kb$chunks) > 0) {
      mean(sapply(kb$chunks, function(c) nchar(c$text)))
    } else 0
  )

  class(stats) <- c("alaquer_kb_stats", "list")
  return(stats)
}

#' Print KB Statistics
#'
#' @param x KB statistics object
#' @param ... Additional arguments
#' @export
print.alaquer_kb_stats <- function(x, ...) {
  cat("Knowledge Base:", x$name, "\n")
  cat("Documents:", x$documents, "\n")
  cat("Chunks:", x$chunks, "\n")
  cat("Embedding Model:", x$embedding_model, "\n")
  cat("Chunk Size:", x$chunk_size, "\n")
  cat("Avg Chunk Size:", round(x$avg_chunk_size), "characters\n")
  cat("Total Text:", format(x$total_text_size, big.mark = ","), "characters\n")
  cat("Created:", format(x$created, "%Y-%m-%d %H:%M:%S"), "\n")
  invisible(x)
}

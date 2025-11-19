test_that("Vector knowledge base creation works", {
  kb <- create_vector_kb(
    name = "TestKB",
    embedding_model = "nomic-embed-text",
    chunk_size = 500,
    chunk_overlap = 100
  )

  expect_s3_class(kb, "alaquer_vector_kb")
  expect_equal(kb$name, "TestKB")
  expect_equal(kb$chunk_size, 500)
  expect_equal(kb$chunk_overlap, 100)
})

test_that("Smart chunking works", {
  text <- paste(rep("This is a test sentence.", 20), collapse = " ")

  chunks <- smart_chunk_text(text, chunk_size = 50, overlap = 10)

  expect_type(chunks, "character")
  expect_true(length(chunks) > 1)

  # Check that chunks have reasonable sizes
  for (chunk in chunks) {
    expect_true(nchar(chunk) > 0)
  }
})

test_that("Cosine similarity works", {
  v1 <- c(1, 2, 3)
  v2 <- c(1, 2, 3)

  # Identical vectors should have similarity of 1
  sim <- cosine_similarity(v1, v2)
  expect_equal(sim, 1.0, tolerance = 0.01)

  # Orthogonal vectors
  v3 <- c(1, 0, 0)
  v4 <- c(0, 1, 0)
  sim2 <- cosine_similarity(v3, v4)
  expect_equal(sim2, 0.0, tolerance = 0.01)
})

test_that("KB statistics work", {
  kb <- create_vector_kb("TestKB")

  # Add mock data
  kb$documents <- list(
    doc1 = "This is document 1",
    doc2 = "This is document 2"
  )

  kb$chunks <- list(
    list(text = "This is chunk 1"),
    list(text = "This is chunk 2"),
    list(text = "This is chunk 3")
  )

  stats <- get_kb_statistics(kb)

  expect_equal(stats$name, "TestKB")
  expect_equal(stats$documents, 2)
  expect_equal(stats$chunks, 3)
  expect_s3_class(stats, "alaquer_kb_stats")
})

test_that("KB save and load works", {
  temp_file <- tempfile(fileext = ".rds")

  kb <- create_vector_kb("TestKB")
  kb$documents <- list(doc1 = "Test document")

  # Save
  result <- save_vector_kb(kb, temp_file)
  expect_true(result)
  expect_true(file.exists(temp_file))

  # Load
  loaded_kb <- load_vector_kb(temp_file)
  expect_equal(loaded_kb$name, "TestKB")
  expect_equal(length(loaded_kb$documents), 1)

  # Cleanup
  unlink(temp_file)
})

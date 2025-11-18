#' Enhance Prompt with AI
#'
#' Transform basic keywords into professional, optimized prompts
#'
#' @param input Character string. Basic input or keywords
#' @param length Character string. Desired prompt length: "short", "medium", "long", "very_long" (default: "medium")
#' @param model Character string. Ollama model to use for enhancement
#' @param host Character string. Ollama host URL (default: "http://localhost:11434")
#' @return Character string with enhanced prompt, or original input if enhancement fails
#' @export
#' @examples
#' \dontrun{
#' enhanced <- enhance_prompt(
#'   input = "machine learning basics",
#'   length = "medium",
#'   model = "llama2"
#' )
#' }
enhance_prompt <- function(input,
                          length = "medium",
                          model,
                          host = "http://localhost:11434") {

  # Validate length parameter
  length <- match.arg(length, c("short", "medium", "long", "very_long"))

  # Define enhancement instructions based on length
  instructions <- list(
    short = "Transform this into a clear, concise prompt (1-2 sentences) that is specific and actionable.",
    medium = "Transform this into a well-structured prompt (2-3 sentences) that includes context, specific requirements, and expected outcomes.",
    long = "Transform this into a comprehensive prompt (3-4 sentences) that provides detailed context, specific requirements, constraints, and clearly defined expected outcomes.",
    very_long = "Transform this into an extensive, professional prompt (5+ sentences) that includes comprehensive context, detailed requirements, relevant constraints, examples if applicable, and precisely defined expected outcomes with quality criteria."
  )

  # Build enhancement prompt
  enhancement_prompt <- paste0(
    "You are an expert prompt engineer. Your task is to transform the following input into an optimized, professional prompt.\n\n",
    "Length requirement: ", instructions[[length]], "\n\n",
    "Apply these prompt engineering best practices:\n",
    "1. Be specific and clear about the desired outcome\n",
    "2. Provide relevant context\n",
    "3. Use precise language\n",
    "4. Include any necessary constraints or requirements\n",
    "5. Structure the prompt logically\n\n",
    "Input to enhance: \"", input, "\"\n\n",
    "Enhanced prompt:"
  )

  # Query Ollama for enhancement
  result <- tryCatch({
    response <- ollama_query(
      prompt = enhancement_prompt,
      model = model,
      host = host,
      temperature = 0.7,
      max_tokens = 500
    )

    if (!is.null(response) && !is.null(response$text)) {
      # Clean up the response
      enhanced <- trimws(response$text)
      # Remove quotes if present
      enhanced <- gsub('^["\']|["\']$', '', enhanced)
      return(enhanced)
    } else {
      warning("Failed to enhance prompt, returning original input")
      return(input)
    }

  }, error = function(e) {
    warning(paste("Error enhancing prompt:", e$message))
    return(input)
  })

  return(result)
}

#' Get Prompt Engineering Templates
#'
#' Retrieve pre-built prompt templates for common use cases
#'
#' @return List of prompt templates by category
#' @export
get_prompt_templates <- function() {
  templates <- list(
    analysis = list(
      title = "Data Analysis",
      template = "Analyze the following data and provide insights on {topic}. Focus on {aspects}. Include statistical summaries, trends, and actionable recommendations."
    ),
    coding = list(
      title = "Code Generation",
      template = "Write {language} code that {functionality}. The code should be {qualities} and include appropriate error handling and comments."
    ),
    explanation = list(
      title = "Concept Explanation",
      template = "Explain {concept} in {detail_level} terms. Include {elements} and provide {examples} to illustrate key points."
    ),
    debugging = list(
      title = "Code Debugging",
      template = "Debug the following {language} code that {problem}. Identify the issue, explain why it occurs, and provide a corrected version with explanations."
    ),
    optimization = list(
      title = "Code Optimization",
      template = "Optimize the following code for {optimization_goal}. Maintain functionality while improving {metrics}. Explain the optimizations made."
    ),
    documentation = list(
      title = "Documentation Generation",
      template = "Create comprehensive documentation for {subject}. Include {sections} with clear examples and best practices."
    ),
    research = list(
      title = "Research Summary",
      template = "Provide a comprehensive summary of {topic} including current state, key findings, methodologies, and future directions. Focus on {specific_aspects}."
    ),
    creative = list(
      title = "Creative Writing",
      template = "Write {content_type} about {topic} in {style} style. The tone should be {tone} and target {audience}. Length: approximately {length}."
    )
  )

  return(templates)
}

#' Apply Prompt Template
#'
#' Fill in a prompt template with specific values
#'
#' @param template Character string. Template with {placeholders}
#' @param values Named list. Values to fill in placeholders
#' @return Character string with filled template
#' @export
apply_prompt_template <- function(template, values) {
  result <- template

  for (name in names(values)) {
    placeholder <- paste0("{", name, "}")
    result <- gsub(placeholder, values[[name]], result, fixed = TRUE)
  }

  return(result)
}

#' Analyze Prompt Quality
#'
#' Evaluate the quality of a prompt based on best practices
#'
#' @param prompt Character string. Prompt to analyze
#' @return List with quality score and feedback
#' @export
analyze_prompt_quality <- function(prompt) {
  score <- 0
  feedback <- list()

  # Check length
  word_count <- length(unlist(strsplit(prompt, "\\s+")))
  if (word_count >= 10) {
    score <- score + 20
    feedback$length <- "Good: Adequate length for context"
  } else {
    feedback$length <- "Improve: Prompt is quite short, consider adding more context"
  }

  # Check for specificity
  specific_words <- c("specific", "exactly", "precisely", "particular", "include", "must", "should")
  if (any(sapply(specific_words, function(w) grepl(w, tolower(prompt))))) {
    score <- score + 20
    feedback$specificity <- "Good: Contains specific instructions"
  } else {
    feedback$specificity <- "Improve: Add more specific requirements or constraints"
  }

  # Check for context
  context_words <- c("context", "background", "given", "considering", "based on", "about")
  if (any(sapply(context_words, function(w) grepl(w, tolower(prompt))))) {
    score <- score + 20
    feedback$context <- "Good: Provides context"
  } else {
    feedback$context <- "Improve: Consider adding more background context"
  }

  # Check for clear goal
  goal_words <- c("create", "generate", "analyze", "explain", "write", "develop", "provide")
  if (any(sapply(goal_words, function(w) grepl(paste0("\\b", w, "\\b"), tolower(prompt))))) {
    score <- score + 20
    feedback$goal <- "Good: Has clear action verb/goal"
  } else {
    feedback$goal <- "Improve: Make the desired outcome more explicit"
  }

  # Check for structure
  if (grepl("\\.|\\?|\\n", prompt)) {
    score <- score + 20
    feedback$structure <- "Good: Has sentence structure"
  } else {
    feedback$structure <- "Improve: Use proper sentence structure"
  }

  quality_level <- if (score >= 80) {
    "Excellent"
  } else if (score >= 60) {
    "Good"
  } else if (score >= 40) {
    "Fair"
  } else {
    "Needs Improvement"
  }

  return(list(
    score = score,
    quality_level = quality_level,
    feedback = feedback
  ))
}

#' Get Prompt Engineering Tips
#'
#' Return helpful tips for writing better prompts
#'
#' @return Character vector of tips
#' @export
get_prompt_tips <- function() {
  tips <- c(
    "Be specific: Clearly state what you want the AI to do",
    "Provide context: Give background information relevant to the task",
    "Set constraints: Specify length, format, tone, or other requirements",
    "Use examples: Show what you're looking for when possible",
    "Break it down: For complex tasks, break into smaller steps",
    "Define the audience: Specify who the output is for",
    "Request format: Specify desired output format (list, paragraph, code, etc.)",
    "Iterate: Refine your prompt based on initial results",
    "Use role-playing: Ask AI to take on a specific role or persona",
    "Request reasoning: Ask the AI to explain its thinking process"
  )

  return(tips)
}

#' Suggest Prompt Improvements
#'
#' Analyze a prompt and suggest specific improvements
#'
#' @param prompt Character string. Prompt to analyze
#' @return Character vector of suggestions
#' @export
suggest_prompt_improvements <- function(prompt) {
  suggestions <- character()
  prompt_lower <- tolower(prompt)

  # Check for vague terms
  vague_terms <- c("thing", "stuff", "some", "something", "anything")
  if (any(sapply(vague_terms, function(t) grepl(paste0("\\b", t, "\\b"), prompt_lower)))) {
    suggestions <- c(suggestions, "Replace vague terms with specific nouns or actions")
  }

  # Check for questions vs instructions
  if (!grepl("\\?", prompt) && !grepl("\\b(create|generate|write|explain|analyze|provide)\\b", prompt_lower)) {
    suggestions <- c(suggestions, "Use clear action verbs (create, generate, analyze, explain, etc.)")
  }

  # Check for length
  word_count <- length(unlist(strsplit(prompt, "\\s+")))
  if (word_count < 10) {
    suggestions <- c(suggestions, "Add more detail and context to your prompt")
  }

  # Check for format specification
  if (!grepl("\\b(format|style|tone|length)\\b", prompt_lower)) {
    suggestions <- c(suggestions, "Specify desired format, style, or tone for the output")
  }

  # Check for examples
  if (word_count > 20 && !grepl("\\b(example|like|such as)\\b", prompt_lower)) {
    suggestions <- c(suggestions, "Consider adding examples to clarify your requirements")
  }

  if (length(suggestions) == 0) {
    suggestions <- "Your prompt looks well-structured! Consider testing and iterating based on results."
  }

  return(suggestions)
}

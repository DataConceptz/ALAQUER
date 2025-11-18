#' Get Example Prompts
#'
#' Retrieve 150+ professional example prompts across 10 categories
#'
#' @param category Character string. Specific category to retrieve (optional)
#' @return List of example prompts organized by category
#' @export
#' @examples
#' \dontrun{
#' # Get all prompts
#' all_prompts <- get_example_prompts()
#'
#' # Get prompts from specific category
#' data_prompts <- get_example_prompts("data_analysis")
#' }
get_example_prompts <- function(category = NULL) {

  prompts <- list(

    # Category 1: Data Analysis (20 prompts)
    data_analysis = list(
      name = "Data Analysis",
      prompts = c(
        "Analyze this dataset and identify the top 3 most significant trends, providing statistical evidence and visualizations recommendations.",
        "Perform exploratory data analysis on this dataset, focusing on distribution patterns, outliers, and correlations between variables.",
        "Compare the performance metrics across different groups in this dataset using appropriate statistical tests and provide actionable insights.",
        "Identify potential data quality issues in this dataset including missing values, duplicates, and anomalies.",
        "Create a comprehensive summary statistics report for this dataset including mean, median, mode, standard deviation, and quartiles.",
        "Analyze the time series data to identify seasonal patterns, trends, and potential forecasting opportunities.",
        "Perform clustering analysis on this dataset to identify natural groupings and provide interpretation of each cluster.",
        "Conduct a correlation analysis between variables and identify the strongest positive and negative relationships.",
        "Analyze this survey data and provide insights on response patterns, demographic distributions, and key findings.",
        "Identify the key drivers of the target variable using feature importance analysis and explain their impact.",
        "Perform A/B test analysis on this experiment data and determine statistical significance of the results.",
        "Analyze customer segmentation data and provide detailed profiles for each segment with actionable recommendations.",
        "Examine this dataset for outliers using multiple detection methods and recommend handling strategies.",
        "Analyze the distribution of categorical variables and identify any imbalances or biases in the data.",
        "Perform cohort analysis on this user data to understand retention patterns and behavior changes over time.",
        "Analyze sales data to identify top-performing products, seasonal trends, and revenue optimization opportunities.",
        "Examine the relationship between multiple variables using multivariate analysis techniques.",
        "Analyze customer churn data to identify key factors contributing to customer attrition.",
        "Perform sentiment analysis on text data and provide insights on overall sentiment distribution and key themes.",
        "Analyze geographic data to identify regional patterns, hotspots, and spatial relationships."
      )
    ),

    # Category 2: Academic Research (15 prompts)
    academic_research = list(
      name = "Academic Research",
      prompts = c(
        "Write a comprehensive literature review on [topic], covering key theories, methodologies, recent developments, and gaps in current research.",
        "Design a research methodology for studying [phenomenon], including research questions, data collection methods, and analysis approach.",
        "Critique this research paper focusing on methodology, validity of conclusions, and potential biases or limitations.",
        "Synthesize findings from multiple studies on [topic] and identify common patterns, contradictions, and emerging themes.",
        "Write an abstract for a research paper on [topic] that includes background, methods, key findings, and implications.",
        "Develop a research proposal for [topic] including research questions, significance, methodology, and expected outcomes.",
        "Analyze the theoretical framework of this study and suggest alternative or complementary theoretical approaches.",
        "Compare and contrast different research methodologies suitable for investigating [research question].",
        "Write a discussion section interpreting these research findings in the context of existing literature and theory.",
        "Identify ethical considerations and potential ethical issues in conducting research on [sensitive topic].",
        "Develop a systematic approach for conducting a meta-analysis on [topic] including inclusion criteria and analysis methods.",
        "Write a grant proposal for research on [topic] emphasizing significance, innovation, and potential impact.",
        "Analyze the limitations of this study and propose improvements for future research.",
        "Synthesize interdisciplinary perspectives on [topic] from multiple fields and identify areas for cross-disciplinary collaboration.",
        "Write a peer review of this manuscript evaluating its contribution, methodology, and suitability for publication."
      )
    ),

    # Category 3: Creative Writing (15 prompts)
    creative_writing = list(
      name = "Creative Writing",
      prompts = c(
        "Write a compelling short story (500-1000 words) about [theme] with well-developed characters and an unexpected twist ending.",
        "Create a detailed character profile for a protagonist in a [genre] story including background, motivations, conflicts, and character arc.",
        "Write a captivating opening paragraph for a novel that immediately hooks the reader and establishes tone and setting.",
        "Develop a plot outline for a [genre] story with three acts, major plot points, and character development arcs.",
        "Write vivid descriptive prose bringing this scene to life: [scene description], using sensory details and literary devices.",
        "Create compelling dialogue between two characters that reveals their personalities, advances the plot, and maintains natural flow.",
        "Write a poem about [subject] in [style] using [poetic devices] and evoking [emotions].",
        "Develop a unique and consistent narrative voice for a story told from [perspective] about [subject].",
        "Create a detailed world-building document for a [genre] story including geography, culture, history, and social structures.",
        "Write a climactic scene that resolves major conflicts while maintaining tension and emotional impact.",
        "Develop backstory and motivation for an antagonist that makes them complex, understandable, and compelling.",
        "Write a personal essay about [experience] that is reflective, honest, and connects to universal themes.",
        "Create a series of interconnected flash fiction pieces (under 300 words each) exploring [theme].",
        "Write engaging microfiction (under 100 words) that tells a complete story with beginning, middle, and end.",
        "Develop a narrative structure for a non-linear story that effectively uses flashbacks and multiple timelines."
      )
    ),

    # Category 4: Business Strategy (15 prompts)
    business_strategy = list(
      name = "Business Strategy",
      prompts = c(
        "Develop a comprehensive market entry strategy for [product/service] in [market] including target segments, positioning, and go-to-market plan.",
        "Conduct a SWOT analysis for [company/product] and provide strategic recommendations based on the findings.",
        "Create a business model canvas for [business idea] covering key partners, activities, resources, value propositions, and revenue streams.",
        "Analyze competitive landscape for [industry] identifying key players, market dynamics, and opportunities for differentiation.",
        "Develop a growth strategy for [company] including market expansion, product development, and strategic partnerships.",
        "Create a digital transformation roadmap for [traditional business] addressing technology adoption, process changes, and organizational impact.",
        "Analyze customer acquisition and retention strategies for [business] and recommend optimization opportunities.",
        "Develop a pricing strategy for [product/service] considering costs, competition, value perception, and market positioning.",
        "Create a strategic plan for entering a new geographic market including market research, localization, and risk mitigation.",
        "Analyze operational efficiency of [business process] and recommend improvements to reduce costs and increase productivity.",
        "Develop a brand positioning strategy for [company/product] including target audience, unique value proposition, and messaging.",
        "Create a partnership strategy identifying potential partners, value exchange, and collaboration frameworks.",
        "Analyze revenue model options for [business] and recommend optimal monetization approach.",
        "Develop a crisis management plan for [potential business threat] including prevention, response, and recovery strategies.",
        "Create a sustainability and corporate social responsibility strategy aligned with business goals and stakeholder expectations."
      )
    ),

    # Category 5: Technical Support (15 prompts)
    technical_support = list(
      name = "Technical Support",
      prompts = c(
        "Debug this [language] code that is producing [error/unexpected behavior]. Identify the root cause and provide corrected code with explanations.",
        "Explain how to troubleshoot [technical problem] with step-by-step instructions suitable for users with [skill level].",
        "Analyze this error message and provide detailed explanation of what it means, what causes it, and how to resolve it.",
        "Write comprehensive documentation for [software/feature] including installation, configuration, usage, and troubleshooting.",
        "Diagnose performance issues in this [system/application] and recommend optimization strategies with expected impact.",
        "Explain the differences between [technology A] and [technology B], including use cases, advantages, and limitations of each.",
        "Provide a step-by-step guide for setting up [development environment/tool] from scratch on [operating system].",
        "Troubleshoot network connectivity issues with systematic diagnostic approach and resolution steps.",
        "Explain how to migrate from [old technology] to [new technology] with minimal disruption and data integrity.",
        "Diagnose and resolve database performance problems including slow queries, connection issues, and data corruption.",
        "Provide solutions for common [software] issues with detailed steps, screenshots references, and prevention tips.",
        "Explain security best practices for [system/application] including authentication, authorization, and data protection.",
        "Troubleshoot API integration issues including authentication failures, data format problems, and error handling.",
        "Provide guidance on backing up and restoring [system/data] with verification and disaster recovery procedures.",
        "Explain how to diagnose and resolve memory leaks in [application type] with profiling and optimization techniques."
      )
    ),

    # Category 6: Code Development (20 prompts)
    code_development = list(
      name = "Code Development",
      prompts = c(
        "Write clean, efficient [language] code to [functionality] following best practices and including comprehensive error handling.",
        "Refactor this code to improve readability, maintainability, and performance while preserving functionality.",
        "Design a scalable architecture for [application type] considering separation of concerns, extensibility, and maintenance.",
        "Implement [design pattern] in [language] with practical example demonstrating its benefits and use cases.",
        "Write unit tests for this code with good coverage of edge cases, error conditions, and expected behaviors.",
        "Optimize this algorithm for better time and space complexity, explaining the improvements and trade-offs.",
        "Create a RESTful API for [resource] with proper endpoints, request/response formats, authentication, and error handling.",
        "Implement data validation and sanitization for user inputs to prevent security vulnerabilities.",
        "Write asynchronous code in [language] that handles concurrent operations efficiently with proper error handling.",
        "Design and implement a database schema for [application] with proper normalization, indexes, and relationships.",
        "Create a responsive UI component in [framework] that works across different screen sizes and browsers.",
        "Implement caching strategy for [application] to improve performance and reduce server load.",
        "Write a custom hook/utility function in [framework] that solves [problem] in a reusable way.",
        "Implement authentication and authorization system with secure token management and role-based access control.",
        "Create a data processing pipeline that handles [data operation] efficiently with error recovery and logging.",
        "Write code to integrate with [third-party API] including authentication, request handling, and response parsing.",
        "Implement real-time features using [technology] with proper connection management and data synchronization.",
        "Create a command-line tool in [language] with argument parsing, help documentation, and error handling.",
        "Write code to handle file operations including reading, writing, parsing, and error handling for various formats.",
        "Implement search functionality with filtering, sorting, and pagination for large datasets."
      )
    ),

    # Category 7: Learning & Education (15 prompts)
    learning_education = list(
      name = "Learning & Education",
      prompts = c(
        "Explain [complex concept] in simple terms suitable for beginners, using analogies and real-world examples.",
        "Create a comprehensive learning path for mastering [skill/technology] from beginner to advanced level.",
        "Break down [complex topic] into smaller, manageable chunks with clear learning objectives for each section.",
        "Design practice exercises for learning [concept] with increasing difficulty and detailed solutions.",
        "Explain the practical applications and real-world use cases of [theoretical concept] in [field].",
        "Create a study guide for [subject] covering key concepts, formulas, examples, and practice questions.",
        "Explain common misconceptions about [topic] and clarify the correct understanding with examples.",
        "Design a hands-on project for learning [skill] that reinforces key concepts and provides practical experience.",
        "Create an analogy that helps explain [abstract concept] by relating it to familiar everyday experiences.",
        "Develop a troubleshooting guide for common mistakes beginners make when learning [skill/concept].",
        "Explain the historical context and evolution of [concept/technology] to provide deeper understanding.",
        "Create a comparison table explaining differences between [concept A], [concept B], and [concept C].",
        "Design a self-assessment quiz for [topic] that tests understanding at different knowledge levels.",
        "Explain how [concept] works under the hood, revealing the underlying mechanisms and principles.",
        "Create a mental model or framework for understanding and remembering [complex system]."
      )
    ),

    # Category 8: Content Creation (15 prompts)
    content_creation = list(
      name = "Content Creation",
      prompts = c(
        "Write an engaging blog post about [topic] that provides value, incorporates SEO best practices, and encourages reader interaction.",
        "Create compelling social media content for [platform] about [topic] optimized for engagement and shareability.",
        "Write a persuasive product description for [product] highlighting benefits, addressing objections, and including clear call-to-action.",
        "Develop an email marketing campaign for [purpose] with attention-grabbing subject line and compelling body copy.",
        "Create a content calendar for [time period] with diverse topics, formats, and publication schedule for [audience].",
        "Write a case study showcasing [success story] with problem statement, solution approach, results, and testimonials.",
        "Develop video script for [video type] about [topic] with engaging hook, clear structure, and strong closing.",
        "Create infographic content about [topic] with key statistics, insights, and visual information hierarchy.",
        "Write a press release announcing [news] with newsworthy angle, quotes, and relevant company information.",
        "Develop podcast episode outline for discussing [topic] with talking points, guest questions, and segment structure.",
        "Create FAQ content addressing common questions about [topic] with clear, helpful answers.",
        "Write landing page copy for [offer] with compelling headline, benefit-focused content, and conversion optimization.",
        "Develop whitepaper or ebook outline on [topic] with chapter structure, key points, and research requirements.",
        "Create webinar presentation content on [topic] with engaging slides outline, examples, and interactive elements.",
        "Write newsletter content that provides value, maintains brand voice, and encourages continued readership."
      )
    ),

    # Category 9: Problem Solving (15 prompts)
    problem_solving = list(
      name = "Problem Solving",
      prompts = c(
        "Analyze this problem: [problem description]. Break it down into components, identify root causes, and propose solutions.",
        "Apply the 5 Whys technique to get to the root cause of [problem] and develop targeted solutions.",
        "Use first principles thinking to solve [problem] by breaking it down to fundamental truths and reasoning up.",
        "Conduct cost-benefit analysis for different approaches to solving [problem] with quantified trade-offs.",
        "Apply design thinking methodology to [problem] with empathy, ideation, prototyping, and testing phases.",
        "Identify constraints and assumptions in [problem] and explore how changing them opens new solution possibilities.",
        "Use lateral thinking to generate creative, non-obvious solutions to [problem].",
        "Apply systems thinking to understand how different elements of [problem] interact and influence each other.",
        "Develop decision matrix for evaluating multiple solution options to [problem] based on key criteria.",
        "Use reverse engineering to understand how [successful solution] works and apply insights to [your problem].",
        "Identify potential unintended consequences of implementing [solution] and develop mitigation strategies.",
        "Apply Pareto principle (80/20 rule) to identify highest impact interventions for [problem].",
        "Use scenario planning to explore different future possibilities and develop robust solutions for [problem].",
        "Conduct stakeholder analysis for [problem] identifying interests, influence, and optimal engagement approach.",
        "Apply lean thinking to eliminate waste and optimize value delivery in [process/system]."
      )
    ),

    # Category 10: Personal Development (15 prompts)
    personal_development = list(
      name = "Personal Development",
      prompts = c(
        "Create a personal development plan for improving [skill/area] with specific goals, actions, and success metrics.",
        "Analyze my strengths and weaknesses in [area] and provide actionable recommendations for growth.",
        "Develop a habit formation strategy for [desired habit] using behavioral science principles and practical techniques.",
        "Create a time management system for balancing [competing priorities] with specific scheduling and prioritization methods.",
        "Provide guidance on overcoming [specific challenge] with mindset shifts and practical strategies.",
        "Develop a career development plan for transitioning from [current role] to [desired role] with concrete steps.",
        "Create a framework for effective goal setting using SMART criteria and breaking down long-term goals into milestones.",
        "Provide strategies for improving [communication skill] with practice exercises and feedback mechanisms.",
        "Develop a learning strategy for acquiring [new skill] efficiently using evidence-based learning techniques.",
        "Create a decision-making framework for [type of decision] considering values, priorities, and long-term implications.",
        "Provide guidance on building resilience and managing stress in [challenging situation].",
        "Develop a networking strategy for [professional goal] with specific actions and relationship-building approaches.",
        "Create a personal productivity system that works with [your constraints] and supports [your goals].",
        "Provide strategies for improving work-life balance while maintaining high performance in [demanding field].",
        "Develop a self-reflection practice for continuous improvement with structured questions and regular review."
      )
    )
  )

  # Return specific category or all categories
  if (!is.null(category)) {
    if (category %in% names(prompts)) {
      return(prompts[[category]])
    } else {
      warning(paste("Category", category, "not found. Available categories:",
                   paste(names(prompts), collapse = ", ")))
      return(NULL)
    }
  }

  return(prompts)
}

#' Get Prompt Categories
#'
#' Get list of available prompt categories
#'
#' @return Character vector of category names
#' @export
get_prompt_categories <- function() {
  prompts <- get_example_prompts()
  return(names(prompts))
}

#' Get Category Prompt Count
#'
#' Get the number of prompts in each category
#'
#' @return Named numeric vector with prompt counts per category
#' @export
get_category_prompt_counts <- function() {
  prompts <- get_example_prompts()
  counts <- sapply(prompts, function(cat) length(cat$prompts))
  return(counts)
}

#' Search Example Prompts
#'
#' Search for prompts containing specific keywords
#'
#' @param keywords Character string or vector. Search keywords
#' @param category Character string. Specific category to search (optional)
#' @return Data frame with matching prompts
#' @export
#' @examples
#' \dontrun{
#' # Search all categories
#' results <- search_example_prompts("data analysis")
#'
#' # Search specific category
#' results <- search_example_prompts("API", category = "code_development")
#' }
search_example_prompts <- function(keywords, category = NULL) {
  prompts <- if (!is.null(category)) {
    list(get_example_prompts(category))
  } else {
    get_example_prompts()
  }

  if (is.null(prompts)) {
    return(data.frame())
  }

  results <- list()

  for (cat_name in names(prompts)) {
    cat_prompts <- prompts[[cat_name]]$prompts

    for (i in seq_along(cat_prompts)) {
      prompt_text <- cat_prompts[i]

      # Check if any keyword matches
      matches <- sapply(keywords, function(kw) {
        grepl(kw, prompt_text, ignore.case = TRUE)
      })

      if (any(matches)) {
        results[[length(results) + 1]] <- data.frame(
          category = cat_name,
          category_name = prompts[[cat_name]]$name,
          prompt = prompt_text,
          index = i,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(results) == 0) {
    return(data.frame())
  }

  return(do.call(rbind, results))
}

#' Get Random Example Prompt
#'
#' Get a random prompt from specified category or all categories
#'
#' @param category Character string. Specific category (optional)
#' @return Character string with random prompt
#' @export
get_random_prompt <- function(category = NULL) {
  prompts <- if (!is.null(category)) {
    get_example_prompts(category)
  } else {
    # Get random category
    all_prompts <- get_example_prompts()
    cat_name <- sample(names(all_prompts), 1)
    all_prompts[[cat_name]]
  }

  if (is.null(prompts) || length(prompts$prompts) == 0) {
    return("No prompts available")
  }

  return(sample(prompts$prompts, 1))
}

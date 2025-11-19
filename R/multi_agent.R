#' Multi-Agent Workflow System
#'
#' Orchestrate multiple AI agents to collaborate on complex tasks with
#' role-based specialization, task decomposition, and result synthesis.
#'
#' @name multi_agent
NULL

#' Create Agent
#'
#' Define an AI agent with specific role and capabilities.
#'
#' @param name Agent name
#' @param role Agent role/specialty
#' @param model Ollama model to use
#' @param system_prompt System prompt defining agent behavior
#' @param temperature Temperature parameter (default: 0.7)
#' @param max_tokens Maximum tokens (default: NULL)
#' @return Agent configuration list
#' @export
create_agent <- function(name, role, model, system_prompt, temperature = 0.7, max_tokens = NULL) {
  agent <- list(
    name = name,
    role = role,
    model = model,
    system_prompt = system_prompt,
    temperature = temperature,
    max_tokens = max_tokens,
    created = Sys.time(),
    history = list()
  )

  class(agent) <- c("alaquer_agent", "list")
  return(agent)
}

#' Print Agent
#'
#' @param x Agent object
#' @param ... Additional arguments
#' @export
print.alaquer_agent <- function(x, ...) {
  cat("ALAQUER Agent:", x$name, "\n")
  cat("Role:", x$role, "\n")
  cat("Model:", x$model, "\n")
  cat("Temperature:", x$temperature, "\n")
  cat("History entries:", length(x$history), "\n")
  invisible(x)
}

#' Run Agent
#'
#' Execute an agent with a specific task/prompt.
#'
#' @param agent Agent object
#' @param task Task description or user prompt
#' @param context Optional context from previous agents
#' @param host Ollama host (default: "http://localhost:11434")
#' @return Agent response with metadata
#' @export
run_agent <- function(agent, task, context = NULL, host = "http://localhost:11434") {
  start_time <- Sys.time()

  # Construct full prompt with system prompt and context
  full_prompt <- agent$system_prompt

  if (!is.null(context) && length(context) > 0) {
    full_prompt <- paste0(
      full_prompt,
      "\n\n## Context from Previous Agents:\n",
      paste(sapply(names(context), function(name) {
        paste0("### ", name, ":\n", context[[name]])
      }), collapse = "\n\n")
    )
  }

  full_prompt <- paste0(
    full_prompt,
    "\n\n## Your Task:\n",
    task
  )

  # Query Ollama
  tryCatch({
    response <- ollama_query(
      prompt = full_prompt,
      model = agent$model,
      host = host,
      temperature = agent$temperature
    )

    duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

    result <- list(
      agent_name = agent$name,
      role = agent$role,
      task = task,
      response = response,
      duration = duration,
      timestamp = Sys.time(),
      success = TRUE,
      error = NULL
    )

    # Add to agent history
    agent$history <- c(agent$history, list(result))

    return(result)

  }, error = function(e) {
    duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

    result <- list(
      agent_name = agent$name,
      role = agent$role,
      task = task,
      response = NULL,
      duration = duration,
      timestamp = Sys.time(),
      success = FALSE,
      error = as.character(e$message)
    )

    return(result)
  })
}

#' Create Agent Team
#'
#' Create a team of specialized agents for collaborative problem-solving.
#'
#' @param team_name Team name
#' @param agents List of agent objects
#' @param coordination_strategy Strategy for agent coordination ("sequential", "parallel", "hierarchical")
#' @return Agent team object
#' @export
create_agent_team <- function(team_name, agents, coordination_strategy = "sequential") {
  if (!coordination_strategy %in% c("sequential", "parallel", "hierarchical")) {
    stop("Invalid coordination_strategy. Must be 'sequential', 'parallel', or 'hierarchical'")
  }

  team <- list(
    team_name = team_name,
    agents = agents,
    coordination_strategy = coordination_strategy,
    created = Sys.time(),
    execution_history = list()
  )

  class(team) <- c("alaquer_agent_team", "list")
  return(team)
}

#' Run Agent Team
#'
#' Execute a team of agents on a complex task.
#'
#' @param team Agent team object
#' @param task Main task description
#' @param host Ollama host (default: "http://localhost:11434")
#' @return Team execution results
#' @export
run_agent_team <- function(team, task, host = "http://localhost:11434") {
  start_time <- Sys.time()

  message("Starting agent team: ", team$team_name)
  message("Strategy: ", team$coordination_strategy)
  message("Agents: ", length(team$agents))

  results <- list()
  context <- list()

  if (team$coordination_strategy == "sequential") {
    # Sequential execution - each agent builds on previous results
    for (i in seq_along(team$agents)) {
      agent <- team$agents[[i]]
      message("\n[", i, "/", length(team$agents), "] Running agent: ", agent$name, " (", agent$role, ")")

      result <- run_agent(agent, task, context, host)
      results[[agent$name]] <- result

      # Add successful results to context for next agent
      if (result$success && !is.null(result$response)) {
        context[[agent$name]] <- result$response
      }

      message("  Duration: ", round(result$duration, 2), "s")
      if (!result$success) {
        message("  Error: ", result$error)
      }
    }

  } else if (team$coordination_strategy == "parallel") {
    # Parallel execution - all agents work independently
    message("\nRunning all agents in parallel...")

    if (requireNamespace("parallel", quietly = TRUE)) {
      n_cores <- min(length(team$agents), parallel::detectCores() - 1)
      cl <- parallel::makeCluster(n_cores)

      tryCatch({
        parallel::clusterExport(cl, c("task", "host"), envir = environment())
        results_list <- parallel::parLapply(cl, team$agents, function(agent) {
          run_agent(agent, task, NULL, host)
        })
      }, finally = {
        parallel::stopCluster(cl)
      })

      # Convert to named list
      for (result in results_list) {
        results[[result$agent_name]] <- result
      }
    } else {
      # Fallback to sequential if parallel not available
      for (agent in team$agents) {
        result <- run_agent(agent, task, NULL, host)
        results[[agent$name]] <- result
      }
    }

  } else if (team$coordination_strategy == "hierarchical") {
    # Hierarchical: all agents work, then synthesizer combines
    message("\nPhase 1: All agents working on task...")

    # All agents work on the task
    for (i in seq_along(team$agents)) {
      agent <- team$agents[[i]]
      message("  [", i, "/", length(team$agents), "] ", agent$name)

      result <- run_agent(agent, task, NULL, host)
      results[[agent$name]] <- result

      if (result$success && !is.null(result$response)) {
        context[[agent$name]] <- result$response
      }
    }

    # Synthesize results (use first agent as synthesizer or create dedicated one)
    message("\nPhase 2: Synthesizing results...")
    synthesis_prompt <- paste0(
      "You are a synthesis agent. Review all the responses from the team and create a comprehensive, unified answer.\n\n",
      "Original task: ", task
    )

    synthesizer <- create_agent(
      name = "Synthesizer",
      role = "Result Synthesis",
      model = team$agents[[1]]$model,
      system_prompt = synthesis_prompt,
      temperature = 0.5
    )

    synthesis_result <- run_agent(synthesizer, "Synthesize the team's responses into a cohesive answer.", context, host)
    results[["_synthesis"]] <- synthesis_result
  }

  total_duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  team_result <- list(
    team_name = team$team_name,
    task = task,
    strategy = team$coordination_strategy,
    results = results,
    total_duration = total_duration,
    timestamp = Sys.time(),
    success = all(sapply(results, function(r) r$success))
  )

  # Add to team history
  team$execution_history <- c(team$execution_history, list(team_result))

  message("\nTeam execution complete in ", round(total_duration, 2), "s")

  class(team_result) <- c("alaquer_team_result", "list")
  return(team_result)
}

#' Create Default Agent Team
#'
#' Create a pre-configured team of specialist agents.
#'
#' @param team_type Type of team ("research", "coding", "creative", "analysis")
#' @param model Default model for all agents (default: "llama3.2")
#' @return Agent team object
#' @export
create_default_agent_team <- function(team_type = "research", model = "llama3.2") {
  if (team_type == "research") {
    agents <- list(
      create_agent(
        name = "Researcher",
        role = "Information Gathering",
        model = model,
        system_prompt = "You are a research specialist. Your role is to gather comprehensive information, identify key facts, and provide detailed background on topics. Focus on accuracy and thoroughness."
      ),
      create_agent(
        name = "Analyst",
        role = "Critical Analysis",
        model = model,
        system_prompt = "You are an analytical expert. Your role is to analyze information critically, identify patterns, evaluate evidence, and draw insightful conclusions. Be objective and rigorous."
      ),
      create_agent(
        name = "Synthesizer",
        role = "Knowledge Integration",
        model = model,
        system_prompt = "You are a synthesis specialist. Your role is to integrate diverse information, connect ideas, and present coherent, comprehensive summaries. Focus on clarity and completeness."
      )
    )

    return(create_agent_team("Research Team", agents, "sequential"))

  } else if (team_type == "coding") {
    agents <- list(
      create_agent(
        name = "Architect",
        role = "System Design",
        model = model,
        system_prompt = "You are a software architect. Your role is to design system architecture, identify components, plan data structures, and establish design patterns. Think about scalability and maintainability."
      ),
      create_agent(
        name = "Developer",
        role = "Implementation",
        model = model,
        system_prompt = "You are a software developer. Your role is to write clean, efficient, well-documented code. Follow best practices and write production-ready implementations."
      ),
      create_agent(
        name = "Reviewer",
        role = "Code Review",
        model = model,
        system_prompt = "You are a code reviewer. Your role is to review code for bugs, security issues, performance problems, and adherence to best practices. Provide constructive feedback."
      )
    )

    return(create_agent_team("Coding Team", agents, "sequential"))

  } else if (team_type == "creative") {
    agents <- list(
      create_agent(
        name = "Ideator",
        role = "Idea Generation",
        model = model,
        system_prompt = "You are a creative ideator. Your role is to generate diverse, innovative ideas and approaches. Think outside the box and explore unconventional solutions.",
        temperature = 0.9
      ),
      create_agent(
        name = "Storyteller",
        role = "Narrative Development",
        model = model,
        system_prompt = "You are a storyteller. Your role is to develop compelling narratives, create engaging content, and craft memorable experiences. Focus on emotion and impact.",
        temperature = 0.8
      ),
      create_agent(
        name = "Editor",
        role = "Content Refinement",
        model = model,
        system_prompt = "You are an editor. Your role is to refine content, improve clarity, enhance flow, and ensure quality. Polish and perfect the creative output.",
        temperature = 0.6
      )
    )

    return(create_agent_team("Creative Team", agents, "sequential"))

  } else if (team_type == "analysis") {
    agents <- list(
      create_agent(
        name = "Data Analyst",
        role = "Data Analysis",
        model = model,
        system_prompt = "You are a data analyst. Your role is to analyze data, identify trends, perform statistical analysis, and extract insights. Be precise and data-driven."
      ),
      create_agent(
        name = "Domain Expert",
        role = "Domain Knowledge",
        model = model,
        system_prompt = "You are a domain expert. Your role is to provide specialized domain knowledge, interpret findings in context, and offer expert insights. Apply deep expertise."
      ),
      create_agent(
        name = "Strategist",
        role = "Strategic Recommendations",
        model = model,
        system_prompt = "You are a strategist. Your role is to develop actionable strategies, make recommendations, and plan next steps based on analysis. Think practically and strategically."
      )
    )

    return(create_agent_team("Analysis Team", agents, "sequential"))

  } else {
    stop("Invalid team_type. Must be 'research', 'coding', 'creative', or 'analysis'")
  }
}

#' Create Workflow
#'
#' Define a multi-step workflow with agents and tasks.
#'
#' @param workflow_name Workflow name
#' @param steps List of workflow steps, each with agent and task
#' @return Workflow object
#' @export
create_workflow <- function(workflow_name, steps) {
  workflow <- list(
    workflow_name = workflow_name,
    steps = steps,
    created = Sys.time(),
    executions = list()
  )

  class(workflow) <- c("alaquer_workflow", "list")
  return(workflow)
}

#' Execute Workflow
#'
#' Run a multi-step workflow with conditional logic and branching.
#'
#' @param workflow Workflow object
#' @param initial_input Initial input/task
#' @param host Ollama host (default: "http://localhost:11434")
#' @return Workflow execution results
#' @export
execute_workflow <- function(workflow, initial_input, host = "http://localhost:11434") {
  start_time <- Sys.time()

  message("Executing workflow: ", workflow$workflow_name)
  message("Steps: ", length(workflow$steps))

  results <- list()
  current_context <- list()
  current_input <- initial_input

  for (i in seq_along(workflow$steps)) {
    step <- workflow$steps[[i]]

    message("\n--- Step ", i, ": ", step$name, " ---")

    # Check if step has a condition
    if (!is.null(step$condition)) {
      should_execute <- tryCatch({
        eval(parse(text = step$condition), envir = list(results = results))
      }, error = function(e) {
        warning("Error evaluating condition: ", e$message)
        TRUE
      })

      if (!should_execute) {
        message("Skipping step (condition not met)")
        next
      }
    }

    # Prepare task for this step
    if (!is.null(step$task_template)) {
      # Use template with variable substitution
      task <- step$task_template
      # Simple variable substitution
      task <- gsub("\\{\\{input\\}\\}", current_input, task)
    } else {
      task <- current_input
    }

    # Run agent
    result <- run_agent(step$agent, task, current_context, host)
    results[[step$name]] <- result

    message("Duration: ", round(result$duration, 2), "s")

    # Update context and input for next step
    if (result$success && !is.null(result$response)) {
      current_context[[step$name]] <- result$response
      current_input <- result$response
    }

    # Check for early termination
    if (!result$success && !is.null(step$on_error)) {
      if (step$on_error == "stop") {
        message("Stopping workflow due to error")
        break
      }
    }
  }

  total_duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  workflow_result <- list(
    workflow_name = workflow$workflow_name,
    initial_input = initial_input,
    steps_executed = length(results),
    results = results,
    total_duration = total_duration,
    timestamp = Sys.time(),
    success = all(sapply(results, function(r) r$success))
  )

  workflow$executions <- c(workflow$executions, list(workflow_result))

  message("\nWorkflow complete in ", round(total_duration, 2), "s")

  class(workflow_result) <- c("alaquer_workflow_result", "list")
  return(workflow_result)
}

#' Debate Agents
#'
#' Create a debate between agents with different perspectives.
#'
#' @param topic Debate topic
#' @param agents List of agents with different perspectives
#' @param rounds Number of debate rounds (default: 3)
#' @param host Ollama host (default: "http://localhost:11434")
#' @return Debate results
#' @export
debate_agents <- function(topic, agents, rounds = 3, host = "http://localhost:11434") {
  message("Starting agent debate on: ", topic)
  message("Participants: ", length(agents), " agents")
  message("Rounds: ", rounds)

  debate_history <- list()
  debate_context <- list()

  for (round in 1:rounds) {
    message("\n=== Round ", round, " ===")

    round_results <- list()

    for (agent in agents) {
      # Prepare debate prompt
      debate_prompt <- paste0(
        "You are participating in a debate. Topic: ", topic, "\n\n",
        if (length(debate_context) > 0) {
          paste0("Previous arguments:\n",
                 paste(sapply(names(debate_context), function(name) {
                   paste0("- ", name, ": ", debate_context[[name]])
                 }), collapse = "\n"),
                 "\n\n")
        } else "",
        "Present your argument or response."
      )

      result <- run_agent(agent, debate_prompt, NULL, host)
      round_results[[agent$name]] <- result

      if (result$success && !is.null(result$response)) {
        debate_context[[agent$name]] <- result$response
        message(agent$name, ": ", substr(result$response, 1, 100), "...")
      }
    }

    debate_history[[paste0("round_", round)]] <- round_results
  }

  # Create summary agent
  summarizer <- create_agent(
    name = "Moderator",
    role = "Debate Summary",
    model = agents[[1]]$model,
    system_prompt = "You are a debate moderator. Summarize the key points from all perspectives and provide a balanced conclusion.",
    temperature = 0.5
  )

  summary_prompt <- paste0(
    "Summarize this debate on: ", topic, "\n\n",
    "Provide a balanced summary of all perspectives presented."
  )

  summary <- run_agent(summarizer, summary_prompt, debate_context, host)

  debate_result <- list(
    topic = topic,
    participants = length(agents),
    rounds = rounds,
    history = debate_history,
    summary = summary,
    timestamp = Sys.time()
  )

  class(debate_result) <- c("alaquer_debate_result", "list")
  return(debate_result)
}

#' Print Team Result
#'
#' @param x Team result object
#' @param ... Additional arguments
#' @export
print.alaquer_team_result <- function(x, ...) {
  cat("ALAQUER Team Result:", x$team_name, "\n")
  cat("Strategy:", x$strategy, "\n")
  cat("Duration:", round(x$total_duration, 2), "seconds\n")
  cat("Success:", x$success, "\n")
  cat("\nAgent Results:\n")
  for (name in names(x$results)) {
    result <- x$results[[name]]
    cat("  ", name, "(", result$role, "):",
        if (result$success) "Success" else paste("Failed:", result$error), "\n")
  }
  invisible(x)
}

test_that("Agent creation works", {
  agent <- create_agent(
    name = "TestAgent",
    role = "Testing",
    model = "llama3.2",
    system_prompt = "You are a test agent",
    temperature = 0.7
  )

  expect_s3_class(agent, "alaquer_agent")
  expect_equal(agent$name, "TestAgent")
  expect_equal(agent$role, "Testing")
  expect_equal(agent$model, "llama3.2")
})

test_that("Agent team creation works", {
  agent1 <- create_agent(
    name = "Agent1",
    role = "Role1",
    model = "llama3.2",
    system_prompt = "Test"
  )

  agent2 <- create_agent(
    name = "Agent2",
    role = "Role2",
    model = "llama3.2",
    system_prompt = "Test"
  )

  team <- create_agent_team(
    team_name = "TestTeam",
    agents = list(agent1, agent2),
    coordination_strategy = "sequential"
  )

  expect_s3_class(team, "alaquer_agent_team")
  expect_equal(team$team_name, "TestTeam")
  expect_equal(length(team$agents), 2)
  expect_equal(team$coordination_strategy, "sequential")
})

test_that("Default agent teams can be created", {
  research_team <- create_default_agent_team("research", "llama3.2")
  expect_s3_class(research_team, "alaquer_agent_team")
  expect_equal(length(research_team$agents), 3)

  coding_team <- create_default_agent_team("coding", "llama3.2")
  expect_equal(length(coding_team$agents), 3)

  creative_team <- create_default_agent_team("creative", "llama3.2")
  expect_equal(length(creative_team$agents), 3)

  analysis_team <- create_default_agent_team("analysis", "llama3.2")
  expect_equal(length(analysis_team$agents), 3)
})

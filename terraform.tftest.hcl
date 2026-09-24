mock_provider "aws" {
}

run "default_actions_pass_through" {
  command = plan

  variables {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }

  assert {
    condition     = tolist(aws_networkfirewall_firewall_policy.resource.firewall_policy[0].stateless_default_actions)[0] == "aws:forward_to_sfe"
    error_message = "stateless_default_actions should pass through unchanged."
  }

  assert {
    condition     = tolist(aws_networkfirewall_firewall_policy.resource.firewall_policy[0].stateless_fragment_default_actions)[0] == "aws:forward_to_sfe"
    error_message = "stateless_fragment_default_actions should pass through unchanged."
  }
}

run "stateful_rule_group_references_render" {
  command = apply

  variables {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_rule_group_arns = [
      { resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateful-rulegroup/example-1", priority = 1 },
      { resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateful-rulegroup/example-2", priority = 2 },
    ]
  }

  assert {
    condition     = length(aws_networkfirewall_firewall_policy.resource.firewall_policy[0].stateful_rule_group_reference) == 2
    error_message = "Two stateful_rule_group_arns entries should render exactly two stateful_rule_group_reference blocks."
  }

  assert {
    condition     = anytrue([for r in aws_networkfirewall_firewall_policy.resource.firewall_policy[0].stateful_rule_group_reference : r.priority == 1])
    error_message = "stateful_rule_group_arns.priority should pass through unchanged."
  }
}

run "stateless_rule_group_references_render" {
  command = apply

  variables {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateless_rule_group_arns = [
      { resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateless-rulegroup/example-1", priority = 1 },
    ]
  }

  assert {
    condition     = length(aws_networkfirewall_firewall_policy.resource.firewall_policy[0].stateless_rule_group_reference) == 1
    error_message = "One stateless_rule_group_arns entry should render exactly one stateless_rule_group_reference block."
  }
}

run "stateful_engine_options_render" {
  command = plan

  variables {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_default_actions           = ["aws:drop_strict"]
    stateful_engine_options = {
      rule_order = "STRICT_ORDER"
    }
  }

  assert {
    condition     = aws_networkfirewall_firewall_policy.resource.firewall_policy[0].stateful_engine_options[0].rule_order == "STRICT_ORDER"
    error_message = "stateful_engine_options.rule_order should pass through unchanged."
  }

  assert {
    condition     = tolist(aws_networkfirewall_firewall_policy.resource.firewall_policy[0].stateful_default_actions)[0] == "aws:drop_strict"
    error_message = "stateful_default_actions should pass through unchanged."
  }
}

run "no_engine_options_omits_block" {
  command = plan

  variables {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }

  assert {
    condition     = length(aws_networkfirewall_firewall_policy.resource.firewall_policy[0].stateful_engine_options) == 0
    error_message = "stateful_engine_options left unset should omit the stateful_engine_options block."
  }
}

run "tags_pass_through" {
  command = plan

  variables {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    tags = {
      Name = "example-policy"
    }
  }

  assert {
    condition     = aws_networkfirewall_firewall_policy.resource.tags.Name == "example-policy"
    error_message = "tags should pass through unchanged."
  }
}

run "readme_default_example" {
  command = plan

  variables {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_rule_group_arns = [
      { resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateful-rulegroup/example" },
    ]
  }
}

run "readme_strict_order_example" {
  command = plan

  variables {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_default_actions           = ["aws:drop_strict"]

    stateful_engine_options = {
      rule_order = "STRICT_ORDER"
    }

    stateful_rule_group_arns = [
      { resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateful-rulegroup/allow", priority = 1 },
      { resource_arn = "arn:aws:network-firewall:us-east-1:123456789012:stateful-rulegroup/deny", priority = 2 },
    ]
  }
}

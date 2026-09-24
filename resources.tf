resource "random_uuid" "resource" {}

resource "aws_networkfirewall_firewall_policy" "resource" {
  name        = coalesce(var.name, random_uuid.resource.id)
  description = var.description

  firewall_policy {
    stateless_default_actions          = var.stateless_default_actions
    stateless_fragment_default_actions = var.stateless_fragment_default_actions
    stateful_default_actions           = var.stateful_default_actions

    dynamic "stateful_engine_options" {
      for_each = var.stateful_engine_options[*]

      content {
        rule_order              = stateful_engine_options.value.rule_order
        stream_exception_policy = stateful_engine_options.value.stream_exception_policy
      }
    }

    dynamic "stateful_rule_group_reference" {
      for_each = var.stateful_rule_group_arns

      content {
        resource_arn = stateful_rule_group_reference.value.resource_arn
        priority     = stateful_rule_group_reference.value.priority
      }
    }

    dynamic "stateless_rule_group_reference" {
      for_each = var.stateless_rule_group_arns

      content {
        resource_arn = stateless_rule_group_reference.value.resource_arn
        priority     = stateless_rule_group_reference.value.priority
      }
    }
  }

  tags = var.tags
}

output "id" {
  description = "The ID of the firewall policy."
  value       = aws_networkfirewall_firewall_policy.resource.id
}

output "name" {
  description = "The name of the policy."
  value       = aws_networkfirewall_firewall_policy.resource.name
}

output "arn" {
  description = "The ARN of the firewall policy — pass to terraform-aws-network-firewall's firewall_policy_arn."
  value       = aws_networkfirewall_firewall_policy.resource.arn
}

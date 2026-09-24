# terraform-aws-network-firewall-policy

Terraform module for an AWS Network Firewall policy — the stateless
and stateful rule groups a
[`terraform-aws-network-firewall`](https://github.com/kn47ytv9mv/terraform-aws-network-firewall)
endpoint enforces, plus the default actions for traffic no rule group
matches.

## Cost

A firewall policy has no charge of its own — see
`terraform-aws-network-firewall`'s Cost section for where Network
Firewall's real charges originate.

## Design

`stateless_default_actions` commonly includes `'aws:forward_to_sfe'`
— without it, no traffic ever reaches the stateful rule groups this
policy references, since stateless rules (and their default actions)
are evaluated first, on every packet, before the stateful engine sees
anything.

`stateful_rule_group_arns`' `priority` only matters when
`stateful_engine_options.rule_order` is `'STRICT_ORDER'` — AWS's
default (`'DEFAULT_ACTION_ORDER'`) groups by action instead, ignoring
declared priority. `stateless_rule_group_arns`' `priority` has no such
condition: stateless rule groups always evaluate in a strict, explicit
order.

`stateful_default_actions` is only accepted by AWS alongside
`'STRICT_ORDER'` — leave both null together for the default
action-grouped behavior.

## Usage

```hcl
module "policy" {
  source = "kn47ytv9mv/network-firewall-policy/aws"

  stateless_default_actions          = ["aws:forward_to_sfe"]
  stateless_fragment_default_actions = ["aws:forward_to_sfe"]

  stateful_rule_group_arns = [
    { resource_arn = module.rule_group.arn }
  ]
}
```

Or directly from this repository, strict rule ordering across two
stateful rule groups:

```hcl
module "policy" {
  source = "github.com/kn47ytv9mv/terraform-aws-network-firewall-policy"

  stateless_default_actions          = ["aws:forward_to_sfe"]
  stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  stateful_default_actions           = ["aws:drop_strict"]

  stateful_engine_options = {
    rule_order = "STRICT_ORDER"
  }

  stateful_rule_group_arns = [
    { resource_arn = module.allow_list.arn, priority = 1 },
    { resource_arn = module.deny_list.arn, priority = 2 },
  ]
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.3 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| name | Name of the firewall policy. If null, a unique name is generated. | `null` | no |
| description | A description of the firewall policy. | `null` | no |
| stateless_default_actions | Actions for a packet that does not match any stateless rule (e.g. ['aws:forward_to_sfe'] to hand it to the stateful engine, or ['aws:pass']/['aws:drop'] to skip stateful inspection entirely). | `null` | no |
| stateless_fragment_default_actions | Actions for a fragmented packet that does not match any stateless rule. Same shape and same available actions as stateless_default_actions. | `null` | no |
| stateful_default_actions | Actions for a packet the stateful engine evaluates with no rule matching it (e.g. ['aws:drop_strict']). Only used when stateful_engine_options.rule_order is 'STRICT_ORDER' — AWS rejects this otherwise. | `null` | no |
| stateful_engine_options | How the stateful engine evaluates its rule groups. rule_order is 'DEFAULT_ACTION_ORDER' (action-grouped, AWS's default) or 'STRICT_ORDER' (rule groups evaluated strictly by stateful_rule_group_arns priority — pairs with stateful_default_actions). If null, AWS's own default applies. | `null` | no |
| stateful_rule_group_arns | Stateful rule groups this policy references, from terraform-aws-network-firewall-rule-group's arn output. priority sets evaluation order when stateful_engine_options.rule_order is 'STRICT_ORDER'; ignored otherwise. | `[]` | no |
| stateless_rule_group_arns | Stateless rule groups this policy references, from terraform-aws-network-firewall-rule-group's arn output. priority sets evaluation order and is always required — stateless rule groups always evaluate in a strict, explicit order. | `[]` | no |
| tags | A map of tags to assign to the firewall policy. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the firewall policy. |
| arn | The ARN of the firewall policy — pass to terraform-aws-network-firewall's firewall_policy_arn. |
| name | The name of the policy. |

## License

MIT — see [LICENSE.md](LICENSE.md).

variable "name" {
  default     = null
  description = "Name of the firewall policy. If null, a unique name is generated."
}

variable "description" {
  default     = null
  description = "A description of the firewall policy."
}

variable "stateless_default_actions" {
  default     = null
  description = "Actions for a packet that does not match any stateless rule (e.g. ['aws:forward_to_sfe'] to hand it to the stateful engine, or ['aws:pass']/['aws:drop'] to skip stateful inspection entirely)."
}

variable "stateless_fragment_default_actions" {
  default     = null
  description = "Actions for a fragmented packet that does not match any stateless rule. Same shape and same available actions as stateless_default_actions."
}

variable "stateful_default_actions" {
  default     = null
  description = "Actions for a packet the stateful engine evaluates with no rule matching it (e.g. ['aws:drop_strict']). Only used when stateful_engine_options.rule_order is 'STRICT_ORDER' — AWS rejects this otherwise."
}

variable "stateful_engine_options" {
  default     = null
  description = "How the stateful engine evaluates its rule groups. rule_order is 'DEFAULT_ACTION_ORDER' (action-grouped, AWS's default) or 'STRICT_ORDER' (rule groups evaluated strictly by stateful_rule_group_arns priority — pairs with stateful_default_actions). If null, AWS's own default applies."
  type = object({
    rule_order              = optional(string)
    stream_exception_policy = optional(string)
  })
}

variable "stateful_rule_group_arns" {
  default     = []
  description = "Stateful rule groups this policy references, from terraform-aws-network-firewall-rule-group's arn output. priority sets evaluation order when stateful_engine_options.rule_order is 'STRICT_ORDER'; ignored otherwise."
  type = list(object({
    resource_arn = string
    priority     = optional(number)
  }))
}

variable "stateless_rule_group_arns" {
  default     = []
  description = "Stateless rule groups this policy references, from terraform-aws-network-firewall-rule-group's arn output. priority sets evaluation order and is always required — stateless rule groups always evaluate in a strict, explicit order."
  type = list(object({
    resource_arn = string
    priority     = number
  }))
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the firewall policy."
}

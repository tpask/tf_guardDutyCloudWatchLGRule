variable "profile" {
  type = string
}

variable "region" {
  type = string
}

variable "rule_name" {
  type = string
  default =  "guardDutyFindingsToCWLogGroup"
}

variable "log_group" {
  type = string
  default = "/aws/events/guardduty"
}

variable "log_group_retention" {
  type = number
  default = 30
}

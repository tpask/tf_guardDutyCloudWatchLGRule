
#create a rule
resource "aws_cloudwatch_event_rule" "guardduty_event_rule" {
  name        = var.rule_name
  description = "Capture GuardDuty findins and trigger CW Log Group"
  tags = {
    "Name"            = var.rule_name
  }
  event_pattern = <<PATTERN
{
   "source":
         ["aws.guardduty"],
    "detail-type":
        ["GuardDuty Finding"]
}
PATTERN
}

#create log group
resource "aws_cloudwatch_log_group" "guard_duty_log_group" {
  name              = var.log_group
  retention_in_days = var.log_group_retention
  tags = {
    "Name"            = "Guard Duty findings log group name"
  }
}

#define CW event target
resource "aws_cloudwatch_event_target" "cw_target_to_cw_logs" {
  rule      = aws_cloudwatch_event_rule.guardduty_event_rule.name
  target_id = "SendToCWLogGroup"
  #arn       = substr(aws_cloudwatch_log_group.guard_duty_log_group.arn,0,length(aws_cloudwatch_log_group.guard_duty_log_group.arn) - 2)
  arn       = substr(aws_cloudwatch_log_group.guard_duty_log_group.arn,0,length(aws_cloudwatch_log_group.guard_duty_log_group.arn))
}

# perms for CW events to manage a CloudWatch log resource policy
data "aws_iam_policy_document" "cw-event-log-publishing-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]
    resources = ["arn:aws:logs:*"]
    #resources  = ["arn:aws:logs:eu-central-1:<AccountId>:log-group:/aws/events/*:*]
    principals {
      identifiers = ["delivery.logs.amazonaws.com", "events.amazonaws.com"]
      type        = "Service"
    }
  }
}

#attach policy
resource "aws_cloudwatch_log_resource_policy" "cw-rule-log-publishing-policy" {
  policy_document = data.aws_iam_policy_document.cw-event-log-publishing-policy.json
  policy_name     = "cw-rule-log-publishing-policy"
}


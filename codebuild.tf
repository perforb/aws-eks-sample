resource "aws_codebuild_project" "front_end_build" {
  name         = "front-end-build"
  service_role = aws_iam_role.container_build.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE",
    ]
    type = "LOCAL"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = "https://github.com/perforb/front-end"
    report_build_status = false
    type                = "GITHUB"

    git_submodules_config {
      fetch_submodules = false
    }
  }
}

resource "aws_codebuild_source_credential" "example" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "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"
}

resource "aws_codebuild_webhook" "front_end_build" {
  project_name = aws_codebuild_project.front_end_build.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH, PULL_REQUEST_MERGED"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "refs/heads/master"
    }
  }
}

resource "aws_sns_topic" "code_series_notification" {
  name = "code-series-notification"
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.code_series_notification.arn
  policy = data.aws_iam_policy_document.notification_access.json
}

data "aws_iam_policy_document" "notification_access" {
  statement {
    actions = [
      "sns:Publish"
    ]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = [aws_sns_topic.code_series_notification.arn]
  }
}

resource "aws_codestarnotifications_notification_rule" "front_end_build" {
  detail_type = "FULL"
  event_type_ids = [
    "codebuild-project-build-state-failed",
    "codebuild-project-build-state-succeeded",
  ]

  name     = "front-end-build"
  resource = aws_codebuild_project.front_end_build.arn

  target {
    address = "arn:aws:chatbot::${var.aws_account_id}:chat-configuration/slack-channel/notification"
    type    = "AWSChatbotSlack"
  }
}

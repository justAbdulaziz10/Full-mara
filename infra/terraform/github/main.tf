terraform {
  required_providers { github = { source = "integrations/github", version = "~> 6.0" } }
}
provider "github" {
  owner = "justAbdulaziz10"
}

resource "github_branch_protection" "main" {
  repository_id = "Full-mara"
  pattern       = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews = true
    required_approving_review_count = 2
  }

  required_status_checks {
    strict = true
    contexts = ["CI", "Security Suite", "Super Linter"]
  }

  enforce_admins = true
  require_signed_commits = false
}

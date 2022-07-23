terraform {
  required_version = ">=1.0.5"

  backend "s3" {
    bucket         = "kojitechs.github.organizatio"
    dynamodb_table = "terraform-lock"
    key            = "path/env"
    region         = "us-east-1"
    encrypt        = "true"
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

locals{
    repository = {
        repose_1={
            name = "kojitechs-terraform-group-A"
            description = "My REPO is meant to be used only by students that belongs to terraform-group-A"
        }
        repo2={
            name = "kojitechs-terraform-group-B"
            description = "My REPO is meant to be used only by students that belongs to terraform-group-B"
        }
    }
}

resource "github_repository" "kojitechs_repo" {
    for_each = local.repository

    name        = each.value.name
    description = each.value.description
    visibility = "private"
}

# Add a team to the organization
resource "github_team" "all" {
    for_each = {
        for team in csvdecode(file("teams.csv")) :
        team.name => team
    }

    name        = each.value.name
    description = each.value.description
    privacy     = each.value.privacy
    create_default_maintainer = true
}

# resource "github_team_membership" "members" {
#   for_each = { for tm in local.team_members : tm.name => tm }

#   team_id  = each.value.team_id
#   username = each.value.username
#   role     = each.value.role
# }

resource "github_membership" "all" {
  for_each = {
    for member in csvdecode(file("members.csv")) :
    member.username => member
  }

  username = each.value.username
  role     = each.value.role
}
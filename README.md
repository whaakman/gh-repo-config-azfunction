# Enforce branch protection rules

## Overview

The goal of of this webhook is to enforce branch protection rule standards across the entire GitHub organization. Organization wide branch protection rules are set to:
* Branch protection rule is enforced on main branch
* "Require a pull request before merging" option enforced with "Require approvals" option enabled and "Required number of approvals before merging" option set to 1
* "Dismiss stale pull request approvals when new commits are pushed" option is enabled to ensure that existing PR approvals are dismissed when new commits are added to PR
* "Dismiss stale pull request approvals when new commits are pushed" option is enabled to ensure that all PR comments are resolved before merging
* "Require linear history" option is enabled to prevent merge commits from being pushed to matching branches
* "Include administrators" option is enabled to enforce all above mentioned restrictions for administrators


## How it works
We have enabled GitHub webhook to listed to repository events in our GitHub organization. Webhook is pointing to Azure PowerShell function called github-repo-rules. Source code for Azure PowerShell function can be found [here](https://github.com/automagicallyorg/gh-repo-config-azfunction.) 

Azure PowerShell function will configure branch protection rules when triggered with new repo creation. If repo was created without any files committed then Azure PowerShell function will commit an initial README.md file with some basic instructions into the repo and then apply the branch protection rule to the main branch.

Azure PowerShell function uses GitHub REST API to manage branch protection rules in GitHub. More information can be found at [GitHub REST API](https://docs.github.com/en/enterprise-cloud@latest/rest/reference/branches#update-branch-protection).

## Azure infrastructure
Azure PowerShell function is using ghToken variable that is pointing to a ghToken secret storing GitHub BASE64 encoded PAT token in maxghkv Azure KeyVault. This GitHub PAT has repo scope defined and is set to expire on on Mon, Mar 7 2022.

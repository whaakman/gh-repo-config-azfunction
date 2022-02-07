using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$orgName="automagicallyorg"
$Request = $Request.Body
$action  = $Request.action
Write-Host "Action Type:" $Request.action
Write-Host "Repository Name:" $Request.repository.name
Write-Host "Private Repository:" $Request.repository.private

# Header for GitHub API
$ghToken = $env:ghToken
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/vnd.github.v3+json")
$headers.Add("Authorization", "Basic $ghToken")
$headers.Add("Content-Type", "application/json")

$ghRepoName = $Request.repository.name

function ConfigureBranchProtection {
    $bodyConfigureProtection = "{
    `n    `"required_status_checks`": null,
    `n    `"enforce_admins`": true,
    `n    `"required_pull_request_reviews`": {
    `n        `"dismissal_restrictions`": {},
    `n        `"dismiss_stale_reviews`": true,
    `n        `"require_code_owner_reviews`": false,
    `n        `"required_conversation_resolution`": true,
    `n        `"required_approving_review_count`": 1
    `n    },
    `n    `"restrictions`": null
    `n}"
    
    $response = Invoke-RestMethod "https://api.github.com/repos/$orgName/$ghRepoName/branches/main/protection" -Method 'PUT' -Headers $headers -Body $bodyConfigureProtection
    $response | ConvertTo-Json
}
    
function DummyCommit {
    $bodyDummyCommit = "{
    `n  `"branch`": `"main`",
    `n  `"message`": `"Init file to create the initial branch. Please remove and update with a Readme file`",
    `n  `"content`": `"SW5pdGZpbGU=`"
    `n}"

    $response = Invoke-RestMethod "https://api.github.com/repos/$orgName/$ghRepoName/contents/initfile" -Method 'PUT' -Headers $headers -Body $bodyDummyCommit
    $response | ConvertTo-Json
}

if ($action -eq "created")
{
    try {
        Write-Host Configuring branch protection
        ConfigureBranchProtection
    }
    catch {
        Write-Host No branches exist, creating dummy commit to initialize branch.
        DummyCommit
        ConfigureBranchProtection
    }
    finally {
        Write-Host Branch protection configured
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $Request
})

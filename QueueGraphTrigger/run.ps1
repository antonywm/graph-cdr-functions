# Input bindings are passed in via param block.
param([string] $QueueItem, $TriggerMetadata)

#  Resonate Tenant
$clientId = "bcd1bc28-e297-4a84-b458-6b260ef7473f"
$tenantId = "cf2382f9-ad5a-43ac-a83f-e1b810bfeaad"
$clientSecret = 'qQ.5MUFAroxVgY29_P~-Ax4i4M.--mTRq4'

# Write out the queue message and insertion time to the information log.
Write-Host "QueueGraphTrigger PowerShell function processed callId: $QueueItem"
Write-Host "CallId Notification time was: $($TriggerMetadata.InsertionTime)"

# Get OAuth Access Token
$AuthURI = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}
Write-Host "Getting an OAuth web token..."
$tokenRequest = Invoke-WebRequest -Method Post -Uri $AuthURI -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
# Set Access Token
$token = ($tokenRequest.Content | ConvertFrom-Json).access_token

Write-Host "Sending Graph API Request for callrecord [CallID: $QueueItem]"
$callUrl="https://graph.microsoft.com/v1.0/communications/callRecords/$QueueItem"
$headers=@{}
$headers.Add("Authorization", "Bearer $token")
$Request = Invoke-WebRequest -Uri $callUrl -Method GET -Headers $headers

if ($Request.StatusCode -eq "200") {
    Write-Host "200 OK - Call Record Retrieved."
    Push-OutputBinding -Name outputQueueItem -Value $Request.Content
}

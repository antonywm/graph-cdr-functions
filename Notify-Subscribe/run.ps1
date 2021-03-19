# Input bindings are passed in via param block.
param($Timer)

#  Resonate Tenant
$clientId = "bcd1bc28-e297-4a84-b458-6b260ef7473f"
$tenantId = "cf2382f9-ad5a-43ac-a83f-e1b810bfeaad"
$clientSecret = 'qQ.5MUFAroxVgY29_P~-Ax4i4M.--mTRq4'
$clientState="ResonateDevServices-gke945-d5jy9wl-avny2n6"

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

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

# Setting Expiry Time for Subscription
$subscribeExpiry= (Get-Date).adddays(1) | Get-Date -UFormat "%FT%R:00.0000000Z"
Write-Host "Subscription Expiry time set to: $subscribeExpiry"

Write-Host "Sending Subscription Request..."
$headers=@{}
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Bearer $token")
$ReqBody="{
  ""changeType"": ""created,updated"",
  ""notificationUrl"": ""https://resonatedev-graphfuncs.azurewebsites.net/api/NotifyEP-Validate?code=2ammGo6KzjGxW2EPMl/vguMRK//trxJYT6qQz5mkYKi/oy4HVp3Xkg=="",
  ""resource"": ""/communications/callRecords"",
  ""expirationDateTime"": ""$subscribeExpiry"",
  ""clientState"": ""$clientState""
}  "
$response = Invoke-WebRequest -Uri 'https://graph.microsoft.com/v1.0/subscriptions' -Method POST -Headers $headers -ContentType 'application/json' -Body $ReqBody

if ($response.StatusCode -eq "201") {
    Write-Host "Subscription Validated and Created"
}

$responseContent=$response.Content | ConvertFrom-Json
$recvClientState=$responseContent.clientState
if (-not $recvClientState) {
    Write-Host "ERROR! Did not receive ClientState. Expected: $clientState , Received: nothing."
} elseif ($clientState -ne $recvClientState) {
    Write-Host "WARNING! Received Client State does not match. Expected: $clientState , Received: $recvClientState"
} else {
    $subscribeId=$responseContent.id
    Write-Host "SUCCESS! - Subscription ID is: $subscribeId"
}

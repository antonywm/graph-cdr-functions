using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
$clientState="ResonateDevServices-gke945-d5jy9wl-avny2n6"

Write-Host "NotifyEP-Validate PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$validationToken = $Request.Query.validationToken
if ($validationToken) {
    Write-Host "Processing : Subscription Validation"
    Write-Host "Received token is: $validationToken"
    $body = "$validationToken"
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = $body
    })
} else {
    Write-Host "Processing : Notification Received"
    $notifyMsg = $Request.Body.value
    $recvClientState=$notifyMsg.clientState
    if (-not $recvClientState) {
        Write-Host "ERROR! Did not receive ClientState. Expected: $clientState , Received: nothing."
    } elseif ($clientState -ne $recvClientState) {
        Write-Host "WARNING! Received Client State does not match. Expected: $clientState , Received: $recvClientState"
    } else {
        $resourceData=$Request.Body.value.resourceData
        $callId=$resourceData.id
        if ($callId) {
            Write-Host "Received callId is: $callId"
            Write-Host "Sending a 202 ACCEPTED back to Graph"
            Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                StatusCode = [HttpStatusCode]::Accepted
            })
            Push-OutputBinding -Name outputQueueItem -Value $callid
        }
    }
}

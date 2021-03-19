# resonatedev-graphfuncs
Development Functions for calling Microsoft Graph

These functions are to test automation in the following process:

1. Registering to the Graph Notification Service for callrecord notifications
2. Processing webhook notification messages from Graph and pushing to Azure Queue Storage
3. Making Graph API calls to receive the callrecord and pushing to Azure Queue Storage

**Folder Structure:**
The Azure functions automate the steps above and are organized under folders . For example: `resonatedev-graphfuncs\Notify-Subscribe`

- [**/Notify-Subscribe** ](https://github.com/ResonateUCC/resonatedev-graphfuncs/tree/main/Notify-Subscribe) This function creates a notification in Graph and reports on the success of the registration. It sets a 1 day expiry of the webhook and retriggers on a timer to ensure a new registration is made every day.

- [**/NotifyEP-Validate** ](https://github.com/ResonateUCC/resonatedev-graphfuncs/tree/main/NotifyEP-Validate) This function is the notify endpoint and also provides a validation function for when a new webhook registration is made. For new notifications which are sent, the function processes the received data and extracts the callID of the call. This is then pushed to an [Azure Storage Queue](https://docs.microsoft.com/en-us/azure/storage/queues/storage-queues-introduction) called 'receivednotifications'.

- [**/Notify-Subscribe** ](https://github.com/ResonateUCC/resonatedev-graphfuncs/tree/main/Notify-Subscribe) This function creates a notification in Graph and reports on the success of the registration. It sets a 1 day expiry of the webhook and retriggers on a timer to ensure a new registration is made every day.

- [**/QueueGraphTrigger** ](https://github.com/ResonateUCC/resonatedev-graphfuncs/tree/main/QueueGraphTrigger) This function will pop callId's from the notification storage queue and make an API call to Microsoft Graph to retrieve the call record. The received call record is a JSON formatted response which is pushed to another storage queue called 'callrecords' for subsequent post processing.


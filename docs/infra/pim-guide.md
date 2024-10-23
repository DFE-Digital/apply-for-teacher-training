# PIM rights for production access

This document describes the process of elevating your permissions using PIM (Privileged Identity Management) in Azure to administer resources in the test and production subscriptions.

## Instructions

1. Launch the [Azure portal](https://portal.azure.com).
1. Ensure that you are using the "DfE Platform Identity" directory, this is shown under your username at the top right of the GUI. To change directory click on your username at the top right, click on "Switch directory" and then select "DfE Platform Identity".
1. In the search bar at the top of the portal type in "PIM" and select "Azure AD Privileged Identity Management" from the search results.
1. In the new blade that opens select "My roles" from the tasks section of the menu bar on the left.
1. Under the "Activate" section of the menu select "Groups".
1. Chose the group you want to elevate your rights on and click "Activate". This will launch a new panel where you can specify duration and reason which must be completed before you can click Activate.
1. For the test group, this is a self-authorisation process and you can use your elevated rights immediately. For the production group, a request will be sent to the approving users, ask in the #twd_find_and_apply_tech slack channel for someone to approve your request for elevated rights.

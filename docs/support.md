# Support on Apply

There’s one person from Apply on support every week. Next week’s dev is also on hand as the backup support dev.

We've got 2 important documents:

- The [regularly updated rota](https://educationgovuk.sharepoint.com/:x:/s/TeacherServices/EeD2Ew8Ga-NAn9FuH-FpAp8B3MwZk-K-spUebsAF_k9uNw?e=cGoQsD) keeps track of who's on both policy and technical support
- The [Support Playbook](support_playbook.md) doc tells you what to do (and who should do it) for common situations

## What's the purpose of a "support dev"?

Things that a support dev does:

- Unblock support agents by answering questions
- Looking at Sentry errors
- Perform dev-only tasks like running scripts on production
- Improve the [support playbook](support_playbook.md)

And not:

- Fix all the issues - just triage, talk to someone to create a card on backlog

## Weekly handover

We do a 15 minute handover on Mondays at 11:00.

Agenda:

- Say hi
- What happened last week?
- Raise awareness of anything that support should know (big features, comms, incidents/downtime etc)

## Before going on support

- Make sure you have [Zendesk](https://becomingateacher.zendesk.com/agent/dashboard) access. You can ask one of the support leads in `#ts_support` for access.

## Good practice when editing production data

Attach an [audit_comment field](https://github.com/collectiveidea/audited#comments) to any model updates. For example:

```rb
ApplicationReference.update!(
  name: 'Correct name',
  audit_comment: 'Correcting a name following a support request',
)
```

Include the Zendesk URL in the audit comment.

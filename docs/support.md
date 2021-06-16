# Support on Apply

There’s one person from Apply (Candidate + ProVendor) on support every week. Next week’s dev is also on hand as the backup support dev.

We've got 2 important documents:

- The [regularly updated rota](https://docs.google.com/spreadsheets/d/1HnJFMMHwlTK167PgHHifrMl98-598zmyUuhsLNeufRU/edit#gid=0) keeps track of who's on both policy and technical support
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

We do a handover on Mondays at 10:30.

Agenda:

- Say hi
- What happened last week?
- Update the Slack channel subject
- Schedule a handover for next week

## Before going on support

- Make sure you have Zendesk access. You can ask #digital-tools-support to be added as an agent to https://becomingateacher.zendesk.com

## Good practice when editing production data

Attach an [audit_comment field](https://github.com/collectiveidea/audited#comments) to any model updates. For example:

```rb
ApplicationReference.update!(
  name: 'Correct name',
  audit_comment: 'Correcting a name following a support request',
)
```

Include the Zendesk URL in the audit comment.

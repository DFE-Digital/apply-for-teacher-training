# Recruitment Cycle Timetables

**Updated June 2025**

The entire application process is tied to the idea of a recruitment cycle,
which begins with Find opening, followed a week later by Apply opening. And ends with Find closing.

There is an _end of cycle period_ marked by some key events:

| Event                  | Description                                                                                                     |
|------------------------|-----------------------------------------------------------------------------------------------------------------|
| Apply deadline         | The last chance for candidates to submit applications for consideration, unsubmitted applications are cancelled |
| Reject by default date | Any Application still be considered by a provider is considered to have been rejected                           |
| Decline by default     | Any offer still be considered by a candidate is considered to be declined                                       |

The specific deadlines can be viewed in [production](https://www.apply-for-teacher-training.service.gov.uk/publications/recruitment-cycle-timetables)

## How to update or add recruitment cycles

Any changes or additions to the recruitment cycles should be done in production, manually by a developer in the rails console.

Those changes should then be synced across all other environments by running the following code in each environment:
```ruby
ProductionRecruitmentCycleTimetablesAPI::SyncTimetablesWithProduction.new.call
```

So that the test data is also using up-to-date recruitment cycle dates, the following should be run locally and a PR opened to capture changes to the CSV
```ruby
ProductionRecruitmentCycleTimetablesAPI::RefreshSeedData.new.call
```

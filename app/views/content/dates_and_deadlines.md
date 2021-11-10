| **Date and time** | **What happens** |
| --- | --- |
| <%= CycleTimetable.apply_opens.to_s(:govuk_date_and_time) %> | Start of recruitment cycle - candidates can apply for courses. |
| <%= holidays[:christmas][:begins].to_s(:govuk_date) %> to <%= holidays[:christmas][:ends].to_s(:govuk_date) %> | This period is not counted as working days when calculating time to make a decision. |
| <%= holidays[:easter][:begins].to_s(:day_and_month) %> to <%= holidays[:easter][:ends].to_s(:govuk_date) %> | This period is not counted as working days when calculating time to make a decision. |
| 1 July 2022 | Time to make a decision is reduced from 40 working days to 20 working days. |
| <%= CycleTimetable.apply_1_deadline.to_s(:govuk_date_and_time) %> | Candidates can no longer apply for courses, unless they have already applied within this recruitment cycle. |
| <%= CycleTimetable.apply_2_deadline.to_s(:govuk_date_and_time) %> | Candidates can no longer apply for courses. |
| <%= CycleTimetable.reject_by_default.to_s(:govuk_date_and_time) %> | End of recruitment cycle - applications awaiting decisions are automatically rejected. |

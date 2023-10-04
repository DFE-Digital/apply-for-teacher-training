### <%= RecruitmentCycle.cycle_name(RecruitmentCycle.current_year) %> recruitment cycle – current
| **Date and time** | **What happens** |
| --- | --- |
| <%= CycleTimetable.apply_opens.to_fs(:govuk_date_and_time) %> | Start of <%= RecruitmentCycle.cycle_name(RecruitmentCycle.current_year) %> recruitment cycle. Candidates can apply for courses. |
| <%= CycleTimetable.apply_2_deadline.to_fs(:govuk_date_and_time) %> | The last day for all candidates to apply for courses. |
| <%= CycleTimetable.reject_by_default.to_fs(:govuk_date_and_time) %> | End of <%= RecruitmentCycle.cycle_name(RecruitmentCycle.current_year) %> recruitment cycle. Applications awaiting decisions are automatically rejected. |


### <%= RecruitmentCycle.cycle_name(RecruitmentCycle.next_year) %> recruitment cycle

In the <%= RecruitmentCycle.cycle_name(RecruitmentCycle.next_year) %> recruitment cycle, training providers will have more time to make decisions on applications.

Applications from candidates will not be rejected after 40 working days. Instead, if candidates do not receive a decision on an application within 30 working days, they’ll be able to apply for another course.

Training providers will still be able to make a decision after 30 working days on all applications.

| **Date and time** | **What happens** |
| --- | --- |
| <%= CycleTimetable.find_opens(CycleTimetable.next_year).to_fs(:govuk_date_and_time) %> | Candidates can find courses for the <%= RecruitmentCycle.cycle_name(RecruitmentCycle.next_year) %> recruitment cycle on GOV.UK. |
| <%= CycleTimetable.apply_opens(CycleTimetable.next_year).to_fs(:govuk_date_and_time) %> | Start of the <%= RecruitmentCycle.cycle_name(RecruitmentCycle.next_year) %> recruitment cycle. Candidates can apply for courses. |
| <%= CycleTimetable.apply_2_deadline(CycleTimetable.next_year).to_fs(:govuk_date_and_time) %> | The last day for all candidates to apply for courses. |
| <%= CycleTimetable.reject_by_default(CycleTimetable.next_year).to_fs(:govuk_date_and_time) %> | End of <%= RecruitmentCycle.cycle_name(RecruitmentCycle.next_year) %> recruitment cycle. Applications awaiting decisions are automatically rejected. |

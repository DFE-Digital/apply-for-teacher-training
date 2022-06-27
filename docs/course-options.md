# Understanding the different course option fields

The `ApplicationChoice` class has three fields relating to course option. It's important to understand what these do and what the rationale for having them is.

| Field | Description | Answers what question |
| --- | --- | --- |
| `original_course_option` | This field is only written once (when the application is submitted), and does what it says on the tin: it stores the candidate's original choice of course option, so that we always have this available for reporting and auditing purposes. | What course option did the candidate originally select? |
| `current_course_option` | This is generally the most relevant course option field and is considered the single source of truth for the application in its current state. It will always be updated when the provider makes a change to the course, whether before or after making an offer. | What is the course option for this application choice? |
| `course_option` | This field reflects the course option attached to the application choice at the point of making an offer. Once an offer has been made, the `course_option` field no longer changes. | What course option was the candidate offered? |

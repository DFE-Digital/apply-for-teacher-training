# 18. Public ids for qualifications

Date: 2021-01-28

## Status

Accepted

## Context

The Vendor API exposes candidate qualifications and grades for systems to ingest.
Each qualification in the system has an id, which vendor systems use to identify the qualification.
It is therefore important that each qualification coming from the API has a unique id.
We use the database id for a qualification object for this purpose.

An issue arises when we have qualifications that are made up of multiple exams/grades.
See [the ADR on structured grades](./0016-structured-gcse-grades.md) for background on the way gcse qualifications are stored.
API consumers expect one qualification entity per exam/grade.
However, because of the structured grades introduced above, some exams/grades share the same database id.
Therefore, not all the ids for qualifications coming through the API are unique.

## Decision

We initially considered changing the data type of the id field in the API response to a string, to support ids of the form `123`, `123_1`, `123_2`.
Vendors were not able to support that change, so the field had to remain an integer.

The solution for this will be split into two: one for qualifications with a single grade in the API, and one for qualifications which have multiple entities in the API.
The split is not as simple as structured vs unstructured grades since triple science is stored as a structure grade, but surfaced as a single GCSE in the API.
The application_qualifications table will get a new public_id column to store the API id for a qualification.
For qualifications with simple grades (only one exam/grade) (and triple science gcse), the public_id will just be set to the database id of the qualification initially via a data migration.
For qualifications with structured grades (built from multiple exams/grades), the public_id column will be set to `nil`, and the public id will be set inside the structured_grades json, with one id per grade.
A qualification with structured grades could look like this:
```
{
    id: 123
    subject: 'english',
    public_id: nil,
    grade: nil,
    constituent_grades: {
      'English Language': { grade: 'E', public_id: 123 },
      'English Literature': { grade: 'B', public_id: 1093 },
      'Cockney Rhyming Slang': { grade: 'A*', public_id: 1094 }
    },
    level: 'gcse'
}
```
and for completeness, a qualification with a single grade could look like this:
```
{
    id: 1,
    subject: 'french',
    public_id: 1200,
    grade: 'A',
    constituent_grades: nil,
    level: 'gcse'
}
```

In order to keep the change backwards compatible for the API, the first grade inside the structured grades will get the database id of the qualification as its public_id.
The other grades will get a new public_id which is unique among the other qualifications.
To generate this new id, we will take the minimum next available integer for public_ids. We will do this using a postgres sequence to ensure uniqueness.
This would have posed a problem if we were still using the database id column for the public id for simple grade qualifications.
There would have been overlap between database ids and public_ids of qualifications
However, since the new public_id column exists, when any new qualification is added, the public id will be generated so as to not clash with any ids that have come before.

To retain full backwards compatibility (between the app and database) throughout the process, we will add a new column to the application_qualifications table to replace the structured_grades column.
This lets us change the data structure for structured grades safely.

## Consequences

- The each qualification entity will have a globally unique id in the API

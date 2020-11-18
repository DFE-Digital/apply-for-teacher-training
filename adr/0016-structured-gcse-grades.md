# 16. Structured GCSE grades

Date: 2020-11-18

## Status

Accepted

## Context

Since the service launched, candidates have been able to enter details about their academic and other 
relevant qualifications using free text answers for most questions.

We’ve seen that free-text answers can often lead to candidates submitting applications with spelling errors, which may 
reduce their chances of being offered an interview.

There is also some complexity around entering GCSE standard equivalent qualifications; there are a number of different 
English GCSE exams, and science GCSEs can be awarded in a number of different ways.

There are two key differences between English and Science GCSEs
- for English GCSEs they have different certificates and are considered separate qualifications (eg. English Language and English Literature)
- a candidate can enter an 'other English GCSE' qualification and give it a name, eg. Cockney Rhyming Slang. 

We considered two different options for how we store this data in the database 
- as separate records, one for each GCSE qualification
- as a single record with the different qualifications stored in a JSON blob in a `structured_grades` column

Part of the reason for this problem is that the English GCSE form is a single page but is gathering information about 
multiple qualifications.

### Separate records

#### Pros
- The database structure more closely reflects the domain structure of having multiple records for multiple 
qualifications

#### Cons
- Increased code complexity. The `ApplicationForm` would need to have multiple English GCSEs, and anywhere that uses 
the English GCSE data would need to be refactored to handle multiple GCSEs. The grade controller would also have to build 
the `EnglishGCSEGradeForm` from multiple qualifications
- No obvious way to store the name of "other English GCSEs" eg. Cockney Rhyming Slang. One idea was to introduce a new
field to capture this data

### JSON blob in a single record

#### Pros
- The logic for serialising and deserialising the GCSEs to JSON can be encapsulated inside the form object. 
So it has a smaller footprint and impact on the codebase
- Using a JSON blob we can easily store the name of "other English GCSEs" eg. Cockney Rhyming Slang

```
{
    subject: 'english',
    structured_grades: { 'English Language': 'E', 'English Literature': 'E', 'Cockney Rhyming Slang: 'A*'},
    level: 'gcse'
}
```

#### Cons
- Database structure doesn't reflect domain structure

## Decision

We decided to go for the JSON blob approach

- Within the candidate interface, whenever we reference English GCSEs we always discuss them together, rather than 
one at a time, so there is little reason to treat them as separate from that point of view
- We didn't feel that domain logic should necessarily dictate the structure of information in the database, if
  it meant introducing extra code complexity
 

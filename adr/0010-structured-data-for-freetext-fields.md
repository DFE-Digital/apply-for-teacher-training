# 10. Structured data for freetext fields in API responses

Date: 2019-12-16

## Status

Proposal

## Context

Vendors have suggested that it'd be helpful for Apply to supply reference data (similarly to UCAS). To achieve this we need to:

- identify which fields could/should be structured
- identify canonical sources of data for these fields
- add agreed fields to the API responses, and
- provide dummy data in API docs/responses 

The structured reference data that UCAS currently makes available as codes is broadly:

- Course Information (pulled from FIND via the Publish API)
- Institutions
- Degree Subjects
- Qualification types
- Awarding Bodies Reference Codes (e.g. HESA codes related to diversity & demographic info)
- Disabilities
- Academic Years
- Nationalities

Initial feedback from vendors suggests they would specifically like consistency around qualification types, awarding bodies and academic years. A nice to have might be to include institutions.

There will always be cases when codes are not available for certain values. For instance, it may be impossible to obtain reliable lookup data for international qualifications. Therefore, any changes to our API responses should preserve the free-text versions of such fields.

### Findings

The Office of Qualifications and Examinations Regulation (Ofqual) is a non-ministerial government department that regulates qualifications, exams and tests in England. It maintains a downloadable register of qualifications, which is updated daily.

[https://register.ofqual.gov.uk/Download](https://register.ofqual.gov.uk/Download)

The full register consists of four CSV files: Organisations.csv, Qualifications.csv, QualificationUnits.csv and Units.csv

The Learning Records Service (LRS) documentation explicitly refers to Ofqual reference codes when describing input fields for achievement uploads -- see [https://www.gov.uk/government/publications/lrs-batch-toolkit-for-awarding-organisations](https://www.gov.uk/government/publications/lrs-batch-toolkit-for-awarding-organisations). This suggests they use the Ofqual register internally as the source of truth for both institutions and qualifications.

From the "Preparing an achievement batch file" document:

![](0010-structured-data-for-freetext-fields-1.png)

and

![](0010-structured-data-for-freetext-fields-2.png)

Using the Ofqual Register as our source of truth for Institutions and Qualifications seems like a reasonable direction. The entire register is only about one million records, which suggests we could maintain our copy for querying.

```bash
$ wc -l *.csv
      227 Organisations.csv
    42336 Qualifications.csv
   740801 QualificationUnits.csv
   270295 Units.csv
  1053659 total
```

Whether we can reliably match qualifications on our system with this register remains to be seen.

## Decision

### Scope

We have decided to provided structured data for the following areas:

- Institutions & Course information (do we get structured data from Find? LRS)
- Qualification type e.g. A-level, GCSE
- Awarding body e.g. AQA, OCR

We will not provide any structured data for:

- Degree Subjects
- Demographic information (e.g. HESA)
- Nationalities (we use ISO codes)
- Academic year

### Additional fields

The additional structured data will be provided as extra fields in the API responses.

### Reference data

A link to the Ofqual Register download page ([https://register.ofqual.gov.uk/Download](https://register.ofqual.gov.uk/Download)) should be included in our docs, so that vendors who wish to do so can cross-reference Institution and Qualifications data.

## Consequences

### API documentation

Our API documentation must contain examples of structured data provided alongside the relevant free-text fields. It must also explain how vendors can obtain the reference data (lookup tables).

### Application presenter

The presenter code must be adapted to include structured data if the relevant information is available.

### Data model

To expose structured data around institutions and qualification, we need a query service accessing an appropriate data source (e.g. our own database of the Ofqual register) and a method for matching qualifications on our system with the relevant Ofqual codes.

### Data refreshes

We'll also need an automated or manual process for refreshing the Ofqual data in a reasonable timeframe (TBD).
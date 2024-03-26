# HESA Overview

HESA, which stands for the Higher Education Statistics Agency, serves as the official agency in the United Kingdom entrusted with the task of collecting, analyzing, and disseminating data pertaining to higher education institutions, including universities and colleges, as well as their students.

HESA's scope encompasses various aspects of higher education, ranging from student enrollment and qualifications awarded to staff statistics and financial data. The information gathered by HESA plays a crucial role in informing decision-making processes, facilitating planning initiatives, and conducting analyses within the higher education sector. Government agencies, universities, researchers, policymakers, and other stakeholders rely on HESA's data for these purposes.

## Usage in Our Application

In our application, we utilize a combination of data sourced from HESA directly and data mapped within the Department for Education (DfE) reference data. While the DfE reference data ideally serves as the singular source of truth, our migration process to fully integrate HESA data into this framework is still underway.

Below, I outline where HESA data is currently utilized in our application and identify which fields are mapped within the DfE reference data:

| Field                             | HESA Link                                                             | Included in DfE Reference Data? | DfE Reference Data Link                                                                                     |
|-----------------------------------|-----------------------------------------------------------------------|---------------------------------|------------------------------------------------------------------------------------------------------------|
| Sex                               | [HESA Sex Data](https://www.hesa.ac.uk/collection/c23053/e/sexid)                         | No                     | N/A                                                                                                         |
| Ethnicities                       | [HESA Ethnicity Data](https://www.hesa.ac.uk/collection/c23053/e/ethnic)                           | No                     | N/A                                                                                                         |
| Disabilities                      | [HESA Disability Data](https://www.hesa.ac.uk/collection/c23053/e/disable)                       | Yes                      | [DFE Reference Data](https://github.com/DFE-Digital/dfe-reference-data/blob/main/docs/lists_equality_and_diversity.md) |
| Degree Types                      | [HESA Degree Type Data](https://www.hesa.ac.uk/collection/c23053/e/degtype)                       | Yes                      | [DFE Reference Data](https://github.com/DFE-Digital/dfe-reference-data/blob/main/docs/lists_degree_types.md)       |
| Countries                         | [HESA Country Data](https://www.hesa.ac.uk/collection/c23053/e/degctry)                       | Yes                      | [DFE Reference Data](https://github.com/DFE-Digital/dfe-reference-data/blob/main/docs/lists_countries_and_territories.md) |
| Degree Grades                     | [HESA Degree Grade Data](https://www.hesa.ac.uk/collection/c23053/e/degclss)                       | Yes                      | [DFE Reference Data](https://github.com/DFE-Digital/dfe-reference-data/blob/main/docs/lists_degrees.md#dfereferencedatadegreesgrades) |
| Degree Institutions               | [HESA Degree Institution Data](https://www.hesa.ac.uk/collection/c23053/e/degest)                         | Yes                      | [DFE Reference Data](https://github.com/DFE-Digital/dfe-reference-data/blob/main/docs/lists_degrees.md#dfereferencedatadegreesinstitutions) |
| Degree Subjects                   | [HESA Degree Subject Data](https://www.hesa.ac.uk/collection/c23053/e/degsbj)                         | Yes                      | [DFE Reference Data](https://github.com/DFE-Digital/dfe-reference-data/blob/main/docs/lists_degrees.md#dfereferencedatadegreessubjects) |


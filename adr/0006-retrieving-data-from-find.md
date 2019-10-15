# 6. Retrieving Data from Find Service

Date: 2019-10-15

## Status

Accepted

## Context
We are currently working towards meeting these two main user needs:
-   Candidates want to apply to teacher training courses.
-   Training providers want to view applicants who have applied to their courses.

In order to do this the Apply service needs to retrieve data for `Training Providers`, 
`Courses` and `Sites` from the Find service.

The main areas where the Apply Service need data from the Find Service are: 
-   The Apply Service Start Page.
-   The Add a course to Application Page.
-   The Application requirements require the Course type (`Secondary` or `Primary`).
-   The Provider UI needs to know information about the currently signed in Provider.
- The Applications to a certain Provider's courses need to be scoped for the currently signed in Provider.

From an initial discussion and planning session we have decided on two main methods from retrieving data from the Find Service:

`Ask the Find API for all information.`

Keeping all information in the Find Service and contacting the `Find API` every time the Apply Service needs information for `Provider`, `Course` and `Site`.

- This reduces the need to store information within the Apply Service.
- The data from Find is always the latest up-to-date data.
- This can be slow if making many requests to the `Find API`. 
- Apply Service is dependent on the Find Service to function. 


`Create a local copy from Find data`

Create local models for `Provider`, `Course` and `Site`. Populating these models from information from the `Find API` which is called periodically.

- Apply Service is not dependent on the Find Service to function. 
- Faster to lookup local copy that make API request.
- We have more control or local models and only need to request and save data that the Apply Service requires.
- Easier to test local models.
- Requires method to retrieve data from Find and create and update local models.
- Local models can drift from information stored in find if not updated frequently.


## Decision

Create local copies of `Provider`, `Course` and `Site` that can be populated with data from the Find Service.


## Consequences

- Local models for `Provider`, `Course` and `Site` will need to be created.
- `ApplicationChoice` needs to be linked to a unique `Course`/`Site` combination in some way. 
- A system for retrieving data from the Find API and creating or updating local models need to be created.




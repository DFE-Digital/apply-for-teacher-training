# Consolidating wizards and using the DfE Wizard

Date: 2026-08-225

## Problem

The Apply and Manage service uses a number of different solutions for implementing wizards.

Wizards are the way in which long forms are separated out into smaller multistep forms.

### Use of wizards in the service
#### Caching
(At least 7 Wizards use this implementation)

Storing inputs temporarily in cache memory until the wizard has been completed.
- Benefits
  - Records aren't saved in the database until the wizard has been completed.
  - Clears data after a certain length of time.
  - Different tabs can be used to fill out the same form with information.
- Problems
  -  Can cause problems if the cache is cleared and the user hasn't completed the wizard.
#### Database
(At least 6 Wizards use this implementation)

Storing the inputs directly into the database, as draft records, until the wizard has been completed.
- Benefits
  - All changes are saved and stored directly into the database, meaning the user can return at any time.
  - Changes to existing records are stored as "Draft" records until the wizard is completed.
  - Draft records are "published", at the end of the wizard, replacing the previous record (if one exists).
  - Data is not lost due to timing out or cache being cleared.
- Problems
  - Fills up the database with "draft" records.
  - Background jobs are required to periodically delete "draft" records.
  - Additional code must be added to remove "draft" records from the scope.
#### [DfE Wizard](https://github.com/DFE-Digital/dfe-wizard) (technically still caching)
(1 Wizard uses this implementation)

Uses the DfE Wizard to format steps more readably.
  - Benefits
    - Version 1.0.0 uses graph theory to clearly map out the steps of the wizard.
    - Can be setup to use either the session, cache or database to temporarily store inputs until the end of the wizard.

| Interface | Journey                    | Wizard Type |
|-----------|----------------------------|-------------|
| Provider  | User permissions           | Caching     |
| Provider  | Interviews                 | Caching     |
| Provider  | Offers                     | Caching     |
| Provider  | SKE                        | Caching     |
| Provider  | Conditions                 | Caching     |
| Support   | Bulk upload provider users | Caching     |
| Candidate | Degrees                    | Caching     |
| Provider  | Pool invites               | Database    |
| Support   | Service banner             | Database    |
| Candidate | Preferences                | Database    |
| Candidate | English proficiencies      | Database    |
| Candidate | Previous teacher trainings | Database    |
| Candidate | Withdrawal reasons         | Database    |
| Candidate | Course choice              | DfE Wizard  |

## Solution

Since the recent advancements to the DfE Wizard, the Development team has discussed using the DfE Wizard as our
preferred pattern for producing wizards going forward.

When implementing the DfE Wizard strategy, we will favour using SolidCache to store inputs through the wizard journey.

We will begin refactoring a few wizards which use the Database wizard methodology, to replace them with the DfE Wizard strategy.



# 4. Application architecture

Date: 2019-09-25

## Status

Accepted

## Context

We are starting to build a beta of the 'Apply for postgraduate teacher training' service. This service will have 5 distinct user groups, who will have their own interface in the service.

1. Candidates are people who would like to become a teacher.
2. Provider users work for an organisation that provides teacher training, like a school or university
3. Vendors make software that universities use for administration
4. Referees will be provided by candidates and the service will ask them to provide a reference
5. Users within DfE need information about the performance of the service and solve problems

For the architecture of the system, we've discussed 2 options: a microservice architecture and a monolith.

In the microservice architecture, we might split up the service into 3 or more applications - for example an API, a frontend for candidates and a frontend for the provider users. In the monolithic architecture, all components live together in a single application.

## Decision

We've chosen to go for a monolith. After discussing the options, we hypothesise that the microservice architecture for this project does not provide many of the [benefits often associated with microservice approach](https://rubygarage.org/blog/advantages-of-microservices).

For example:

- Teams can work independently: we anticipate that the team size of this project will be limited (less than 20), so communication is less of a problem
- Independent scaling: traffic for this application will be such that the different components will see similar spikes, so independent scaling is not as useful
- Reuse of components: we do not have the need to reuse components in other parts of the organisation

Note that we do use other services and APIs to provide functionality - for example, we use [GOV.UK Notify to send emails](https://www.notifications.service.gov.uk/), and we'll likely use the [Find API to fetch course data](https://github.com/DFE-Digital/manage-courses-backend).

Using a monolith approach will make the project easier to run for developers and easier to deploy.

However, there are problems with a monolith as well. In particular, it can lead to an application that is hard to understand because of a wild growth of classes and files. Additionally, the tests on a large monolith may become slow over time, causing frustration and slowdown in development.

## Consequences

- We need to make sure we structure the application well. Where boundaries exist between responsibilities we will try to maintain them by using modules and other units of separation.
- We need to invest in making tests fast.

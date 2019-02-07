Feature: Candidate registration
  Background: Candidates need to be able to register / sign up to the service
    Given no users exist

  Scenario: Candidate sign up page
     When I visit the home page
     Then I should be redirected to the unauthenticated landing page
      And I should be able to go to the registration page by clicking the sign up link

  Scenario: Candidate registration
      And I am on the registration page
     Then I should be able to enter my details and sign up to the service
      And I should be able to submit the form
     Then I should be redirected to the authenticated root path
      And I should have a user account created with the details I entered

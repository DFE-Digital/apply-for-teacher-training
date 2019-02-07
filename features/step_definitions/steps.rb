Given("no users exist") do
  expect(Candidate.count).to be_zero
end

When("I visit the home page") do
  visit '/'
end

Then("I should be redirected to the unauthenticated landing page") do
  expect(current_path).to eq(unauthenticated_root_path)
end

Then("I should be able to go to the registration page by clicking the sign up link") do
  click_on "Sign up"
  expect(current_path).to eq(new_candidate_registration_path)
end

Given("I am on the registration page") do
  visit new_candidate_registration_path
end

Then("I should be able to enter my details and sign up to the service") do
  fill_in "Title", with: "Mr"
  fill_in "First name", with: "John"
  fill_in "Surname", with: "Smith"
  fill_in "Email", with: "johnsmith@example.com"
  fill_in "Date of birth", with: "01/11/1975"
  choose "candidate_gender_male"
  fill_in "Password", with: "testing123!"
  fill_in "Password confirmation", with: "testing123!"
end

Then("I should be able to submit the form") do
  click_on "Sign up"
end

Then("I should be redirected to the authenticated root path") do
  expect(current_path).to eq(authenticated_root_path)
end

Then("I should have a user account created with the details I entered") do
  fields = :title, :first_name, :surname, :email, :date_of_birth, :gender
  expect(Candidate.last.slice(*fields).values).to match_array([
    "Mr",
    "John",
    "Smith",
    "johnsmith@example.com",
    "01/11/1975".to_date,
    "male"
  ])
end

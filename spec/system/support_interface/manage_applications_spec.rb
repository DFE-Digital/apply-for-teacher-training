require 'rails_helper'

RSpec.feature 'See applications' do
  scenario 'Provider visits application page' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_an_application_has_received_a_reference
    and_i_visit_the_support_page
    then_i_should_see_the_applications
    and_i_should_see_their_reference_statuses

    when_i_click_on_an_application
    then_i_should_be_on_the_application_view_page
  end

  def given_i_am_a_support_user
    page.driver.browser.authorize('test', 'test')
  end

  def and_there_are_applications_in_the_system
    @completed_application = create(:completed_application_form)
    @unsubmitted_application = create(:application_form)
    @application_with_reference = create(:completed_application_form)
  end

  def and_an_application_has_received_a_reference
    action = ReceiveReference.new(
      application_form: @application_with_reference,
      referee_email: @application_with_reference.reload.references.first.email_address,
      feedback: Faker::Lorem.paragraphs(number: 2),
    )
    action.save
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def then_i_should_see_the_applications
    expect(page).to have_content @completed_application.candidate.email_address
    expect(page).to have_content @application_with_reference.candidate.email_address
    expect(page).to have_content @unsubmitted_application.candidate.email_address
  end

  def and_i_should_see_their_reference_statuses
    within "[data-qa='application-form-#{@application_with_reference.id}']" do
      expect(page).to have_content 'Received'
      expect(page).to have_content 'Awaiting response'
    end

    within "[data-qa='application-form-#{@completed_application.id}']" do
      expect(page).to have_content('Awaiting response', count: 2)
    end

    within "[data-qa='application-form-#{@unsubmitted_application.id}']" do
      expect(page).to have_content('Not submitted', count: 2)
    end
  end

  def when_i_click_on_an_application
    click_on @completed_application.candidate.email_address
  end

  def then_i_should_be_on_the_application_view_page
    expect(page).to have_content @completed_application.candidate.email_address
  end
end

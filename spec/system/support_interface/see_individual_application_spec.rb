require 'rails_helper'

RSpec.feature 'See an application' do
  include DfESignInHelpers

  scenario 'Support agent visits application page' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_an_application_has_received_a_reference
    and_i_visit_the_support_page

    when_i_click_on_a_completed_application

    then_i_should_be_on_the_application_view_page
    and_i_should_see_a_summary_of_the_completed_application
    and_i_should_see_their_referees

    when_i_return_to_the_support_page
    and_i_click_on_an_unsubmitted_application
    then_i_should_see_a_summary_of_the_unsubmitted_application

    when_i_return_to_the_support_page
    and_i_click_on_an_application_with_a_reference
    then_i_should_see_the_reference_from_first_referee
    and_i_should_not_see_reference_from_second_referee
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_applications_in_the_system
    @completed_application = create(
      :completed_application_form,
      :with_gcses,
      references_state: :feedback_requested,
    )

    create(:application_choice, application_form: @completed_application, status: 'unsubmitted')

    SubmitApplication.new(@completed_application).call
    @unsubmitted_application = create(:application_form)
    @application_with_reference = create(
      :completed_application_form,
      :with_gcses,
      references_state: :feedback_requested,
    )
  end

  def and_an_application_has_received_a_reference
    @application_with_reference.application_references.first.update(consent_to_be_contacted: true)

    reference = @application_with_reference.reload.application_references.first
    reference.update!(
      feedback: 'This is my feedback',
      safeguarding_concerns: '',
      relationship_correction: '',
    )

    SubmitReference.new(
      reference: reference,
    ).save!
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_a_completed_application
    click_on @completed_application.full_name
  end

  def then_i_should_be_on_the_application_view_page
    expect(page).to have_content @completed_application.candidate.email_address
  end

  def and_i_should_see_a_summary_of_the_completed_application
    within '[data-qa="application-summary"]' do
      [
        @completed_application.support_reference,
        'Submitted',
        'Last updated',
      ].each do |content|
        expect(page).to have_content content
      end
    end

    within '[data-qa="personal-details"]' do
      [
        @completed_application.candidate.email_address,
        @completed_application.first_name,
        @completed_application.last_name,
        @completed_application.phone_number,
      ].each do |content|
        expect(page).to have_content content
      end
    end
  end

  def and_i_should_see_their_referees
    expect(page).to have_selector('[data-qa="reference"]', count: 2)
  end

  def when_i_return_to_the_support_page
    click_on 'Candidates', match: :prefer_exact
  end

  def and_i_click_on_an_unsubmitted_application
    click_on @unsubmitted_application.candidate.email_address
  end

  def then_i_should_see_a_summary_of_the_unsubmitted_application
    within '[data-qa="personal-details"]' do
      expect(page).to have_content 'Phone number'
      expect(page).to have_content 'Not provided'
      expect(page).to have_content @unsubmitted_application.candidate.email_address
    end
  end

  def and_i_click_on_an_application_with_a_reference
    click_on @application_with_reference.full_name
  end

  def then_i_should_see_the_reference_from_first_referee
    within page.all('[data-qa="reference"]').to_a.first do
      expect(page).to have_content('This is my feedback')
      expect(page).to have_content('Given consent for research?')
      expect(page).to have_content('Yes')
    end
  end

  def and_i_should_not_see_reference_from_second_referee
    within page.all('[data-qa="reference"]').to_a.second do
      expect(page).not_to have_content('This is my feedback')
      expect(page).not_to have_content('Given consent for research?')
    end
  end
end

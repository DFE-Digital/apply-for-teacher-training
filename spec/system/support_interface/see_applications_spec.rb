require 'rails_helper'

RSpec.feature 'See applications' do
  include DfESignInHelpers

  scenario 'Support agent visits the list of applications' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_i_visit_the_support_page
    then_i_should_see_the_applications
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_applications_in_the_system
    @completed_application = create(:completed_application_form)
    @unsubmitted_application = create(:application_form)
    @application_with_reference = create(:completed_application_form)
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def then_i_should_see_the_applications
    expect(page).to have_content @completed_application.candidate.email_address
    expect(page).to have_content @application_with_reference.candidate.email_address
    expect(page).to have_content @unsubmitted_application.candidate.email_address
  end
end

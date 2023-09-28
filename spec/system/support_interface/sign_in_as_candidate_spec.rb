require 'rails_helper'

RSpec.feature 'Sign in as candidate' do
  include DfESignInHelpers

  scenario 'Support user signs in as a candidate' do
    given_i_am_a_support_user
    and_there_is_an_application
    when_i_visit_the_application_form_page
    and_click_the_sign_in_button
    then_i_am_logged_in_as_the_candidate
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application
    @application = create(:completed_application_form)
    @application.application_choices << create(:application_choice, :awaiting_provider_decision)
  end

  def when_i_visit_the_application_form_page
    visit support_interface_application_form_path(@application)
  end

  def and_click_the_sign_in_button
    click_button 'Sign in as this candidate'
  end

  def then_i_am_logged_in_as_the_candidate
    expect(page).to have_content 'You are now signed in as candidate'
  end
end

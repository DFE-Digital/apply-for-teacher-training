require 'rails_helper'

RSpec.describe 'Candidate tries to sign up' do
  include SignInHelper

  scenario 'Candidate attempts to sign up without filling in an email address' do
    when_i_go_to_sign_up
    and_i_submit_the_form_without_entering_an_email

    then_i_see_a_validation_error
    and_the_validation_error_is_logged
  end

  def when_i_go_to_sign_up
    visit candidate_interface_sign_up_path
  end

  def and_i_submit_the_form_without_entering_an_email
    click_link_or_button 'Continue'
  end

  def then_i_see_a_validation_error
    expect(page).to have_content 'Error: Enter your email address'
  end

  def and_the_validation_error_is_logged
    validation_error = ValidationError.last
    expect(validation_error).to be_present
    expect(validation_error.details).to have_key('email_address')
    expect(validation_error.user).to be_nil
    expect(validation_error.request_path).to eq(candidate_interface_sign_up_path)
    expect(validation_error.service).to eq('apply')
  end
end

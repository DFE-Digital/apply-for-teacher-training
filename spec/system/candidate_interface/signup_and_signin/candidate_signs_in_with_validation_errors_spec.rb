require 'rails_helper'

RSpec.feature 'Candidate tries to sign up' do
  scenario 'Candidate attempts to sign up without filling in an email address' do
    given_the_pilot_is_open

    given_i_am_a_candidate_without_an_account

    when_i_go_to_sign_up
    and_i_submit_an_email_address_without_checking_terms_of_use

    then_i_see_a_validation_error
    and_the_validation_error_is_logged
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def when_i_go_to_sign_up
    visit candidate_interface_sign_up_path
  end

  def and_i_submit_an_email_address_without_checking_terms_of_use
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    click_on t('continue')
  end

  def then_i_see_a_validation_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/sign_up_form.attributes.accept_ts_and_cs.blank')
  end

  def and_the_validation_error_is_logged
    validation_error = ValidationError.last
    expect(validation_error).to be_present
    expect(validation_error.details).to have_key('accept_ts_and_cs')
    expect(validation_error.user).to be_nil
    expect(validation_error.request_path).to eq(candidate_interface_sign_up_path)
    expect(validation_error.service).to eq('apply')
  end
end

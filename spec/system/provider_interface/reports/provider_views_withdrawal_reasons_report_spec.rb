require 'rails_helper'

RSpec.describe 'Provider views withdrawal reports' do
  include DfESignInHelpers

  scenario 'Provider navigates to report where fewer than 10 candidates have provided withdrawal reasons' do
    given_report_is_not_generated
    and_i_sign_in_as_a_provider_user
    when_i_navigate_to_the_withdrawal_reasons_report
    then_i_see_the_report_without_data
  end

  scenario 'Provider navigates to the report where at least 10 candidates have provided withdrawal reasons' do
    given_report_is_generated
    and_i_sign_in_as_a_provider_user
    when_i_navigate_to_the_withdrawal_reasons_report
    then_i_see_the_report_with_data
  end

private

  def given_report_is_not_generated
    create(:provider_user, :with_dfe_sign_in, email_address: 'email@provider.ac.uk')
  end

  def given_report_is_generated
    provider_user = create(:provider_user, :with_dfe_sign_in, email_address: 'email@provider.ac.uk')
    provider = provider_user.providers.first
    create(:withdrawal_reasons_report, provider:)
  end

  def and_i_sign_in_as_a_provider_user
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_navigate_to_the_withdrawal_reasons_report
    click_on 'Reports'
    click_on 'Withdrawal reasons'
  end

  def then_i_see_the_report_without_data
    expect(page).to have_text 'You will be able to see this report when it contains data from at least 10 candidates.'
  end

  def then_i_see_the_report_with_data
    expect(page).to have_text 'This report shows the reasons for withdrawal selected by candidates from a set list. The question is mandatory and candidates can select more than one reason.'
  end
end

require 'rails_helper'

RSpec.describe 'Editing visa expiry' do
  include DfESignInHelpers

  before do
    FeatureFlag.activate('2027_visa_expiry')
  end

  scenario 'editing visa expiry date' do
    given_i_am_a_support_user
    and_an_application_exists
    and_i_visit_the_application_page
    and_i_click_change_visa_expiry

    when_i_set_a_visa_expiry_date(2.days.from_now)
    and_i_add_an_audit_comment
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_expiry(2.days.from_now)
  end

  def and_i_click_change_visa_expiry
    click_link_or_button 'Change visa expiry'
  end

  def and_an_application_exists
    @form = create(
      :completed_application_form,
      first_nationality: 'Canadian',
      second_nationality: nil,
      right_to_work_or_study: 'yes',
      immigration_status: ApplicationForm::TEMPORARY_IMMIGRATION_STATUSES.sample,
    )
  end

  def and_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def when_i_set_a_visa_expiry_date(date)
    fill_in('Day', with: date.day)
    fill_in('Month', with: date.month)
    fill_in('Year', with: date.year)
  end

  def then_i_see_the_correct_visa_expiry(date)
    within '.govuk-summary-list__row', text: 'Visa expiry' do
      expect(page).to have_text(date.to_fs(:govuk_date))
    end
  end

  def and_i_add_an_audit_comment
    fill_in 'Audit log comment', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_click_save_and_continue
    click_link_or_button 'Save and continue'
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end
end

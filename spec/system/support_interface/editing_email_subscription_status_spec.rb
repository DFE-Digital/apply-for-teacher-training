require 'rails_helper'

RSpec.describe 'Editing email subscription status' do
  include DfESignInHelpers

  scenario 'Support user edits email subscription status', :with_audited do
    given_i_am_a_support_user
    and_an_application_exists
    when_i_visit_the_application_page
    and_i_click_the_change_link_for_applicant_email_status
    and_i_am_on_the_edit_page
    and_i_choose_yes
    and_i_update
    then_i_am_subscribed_to_emails
    and_i_see_the_flash_message_to_show_the_i_am_subscribed

    given_i_click_the_change_link_for_applicant_email_status
    and_i_choose_no
    and_i_update
    then_i_am_unsubscribed_from_emails
    and_i_have_an_audit_of_the_changes
    and_i_see_the_flash_message_to_show_the_i_am_not_subscribed
  end

  def and_i_see_the_flash_message_to_show_the_i_am_subscribed
    within('.govuk-notification-banner__content') do
      expect(page).to have_text('The candidate will now receive marketing emails')
    end
  end

  def and_i_see_the_flash_message_to_show_the_i_am_not_subscribed
    within('.govuk-notification-banner__content') do
      expect(page).to have_text('The candidate will no longer receive marketing emails')
    end
  end

  def and_i_have_an_audit_of_the_changes
    audit = @form.candidate.audits.find do |a|
      a.audited_changes == { 'unsubscribed_from_emails' => [false, true] }
    end

    expect(audit.comment).to eq('too much spam')
  end

  def and_i_am_on_the_edit_page
    expect(page).to have_link('subscription messages', href: 'https://www.gov.uk/service-manual/design/sending-emails-and-text-messages#subscription-messages')
    expect(page).to have_text('Marketing emails are also known as subscription messages')
    expect(page).to have_text('Changing this selection does not unsubscribe the user from transactional messages')
  end

  def then_i_am_subscribed_to_emails
    expect(@form.candidate.subscribed_to_emails?).to be(true)

    within('dt.govuk-summary-list__key', text: 'Subscribed to emails') do
      expect(page).to have_css('~ dd.govuk-summary-list__value p.govuk-body', text: 'Yes')
    end
  end

  def then_i_am_unsubscribed_from_emails
    expect(@form.candidate.reload.subscribed_to_emails?).to be(false)

    within('dt.govuk-summary-list__key', text: 'Subscribed to emails') do
      expect(page).to have_css('~ dd.govuk-summary-list__value p.govuk-body', text: 'No')
    end
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:completed_application_form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:completed_application_form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_for_applicant_email_status
    click_link_or_button('Change applicant email subscription status')
  end

  alias_method :given_i_click_the_change_link_for_applicant_email_status, :and_i_click_the_change_link_for_applicant_email_status

  def and_i_choose_yes
    choose 'Yes'
    fill_in 'support_interface_email_subscription_form[audit_comment]', with: 'not enough spam'
  end

  def and_i_choose_no
    choose 'No'
    fill_in 'support_interface_email_subscription_form[audit_comment]', with: 'too much spam'
  end

  def and_i_update
    click_link_or_button 'Update'
  end
end

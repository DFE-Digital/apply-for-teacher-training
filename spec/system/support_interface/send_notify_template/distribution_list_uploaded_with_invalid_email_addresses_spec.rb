require 'rails_helper'

RSpec.describe 'Send notify template' do
  include DfESignInHelpers

  before do
    stub_notify_template_check
  end

  scenario 'Support user uploads a distribution list with invalid email addresses' do
    given_i_am_a_support_user
    when_i_navigate_to_settings
    and_i_click_on_send_notify_template
    then_i_see_the_send_notify_template_form

    when_i_complete_the_notify_template_form
    and_i_click_on_send
    then_i_see_the_email_address_errors_page
  end

private

  def stub_notify_template_check
    stub_request(:get, 'https://api.notifications.service.gov.uk/v2/template/123456')
      .to_return(status: 200, body: { body: '((link_to_file))' }.to_json, headers: {})
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_navigate_to_settings
    within('.govuk-service-navigation__container') do
      click_link_or_button 'Settings'
    end
  end

  def and_i_click_on_send_notify_template
    within('.app-tab-navigation') do
      click_link_or_button 'Send notify template'
    end
  end

  def then_i_see_the_send_notify_template_form
    expect(page).to have_current_path('/support/settings/notify-template')
    expect(page).to have_title('Send notify template - Settings - Support for Apply - GOV.UK')
    expect(page).to have_element(
      :label,
      text: 'Send a Govuk notify template with attachment',
      class: 'govuk-label govuk-label--l',
    )
    expect(page).to have_element(:li, text: 'Emails will only be sent once suitable and valid files have been provided.')
    expect(page).to have_element(
      :li,
      text: 'Emails are sent in batches of 100, staggered over time depending on how many email addresses are provided.',
    )
    expect(page).to have_element(:li, text: 'The distribution list file must contain the header \'Email address\'.')
    expect(page).to have_element(:li, text: 'Your notify template must include the personalisation \'link_to_file\'.')

    expect(page).to have_field('Notify template id', type: 'text')
    expect(page).to have_field('Distribution list', type: 'file')
    expect(page).to have_field('Attachment', type: 'file')
    expect(page).to have_button('Send')
  end

  def when_i_complete_the_notify_template_form
    fill_in 'Notify template id', with: '123456'
    attach_file 'Distribution list', 'spec/fixtures/send_notify_template/distribution_list_with_invalid_email_addresses.csv'
    attach_file 'Attachment', 'spec/fixtures/send_notify_template/hello_world.txt'
  end

  def and_i_click_on_send
    click_link_or_button 'Send'
  end

  def then_i_see_the_email_address_errors_page
    expect(page).to have_current_path('/support/settings/send-notify-template')
    expect(page).to have_title('Error: Send notify template - Settings - Support for Apply - GOV.UK')
    expect(page).to have_element(:h1, text: 'Error sending notify template - Settings', class: 'govuk-heading-l')

    within('.govuk-error-summary') do
      expect(page).to have_element(:h2, text: 'There is a problem', class: 'govuk-error-summary__title')
      expect(page).to have_element(
        :div,
        text: 'You need to fix 2 errors related to specific rows',
        class: 'govuk-error-summary__body',
      )
    end

    expect(page).to have_element(
      :h2,
      text: 'distribution_list_with_invalid_email_addresses.csv',
      class: 'govuk-heading-m',
    )

    within('.govuk-table') do
      within('.govuk-table__head') do
        expect(page).to have_element(:th, text: '1', class: 'govuk-table__header')
        expect(page).to have_element(:th, text: 'Email address', class: 'govuk-table__header')
      end

      within('.govuk-table__body') do
        within('#row_3') do
          expect(page).to have_element(:td, text: '3', class: 'govuk-table__cell')
          expect(page).to have_element(:td, text: 'Invalid email address john doe', class: 'govuk-table__cell')
        end

        within('#row_4') do
          expect(page).to have_element(:td, text: '4', class: 'govuk-table__cell')
          expect(page).to have_element(:td, text: 'Invalid email address joe bloggs', class: 'govuk-table__cell')
        end
      end
    end

    expect(page).to have_element(
      :p,
      text: 'Only showing rows with errors',
      class: 'govuk-body govuk-!-text-align-centre secondary-text',
    )

    expect(page).to have_link('Upload file again')
  end
end

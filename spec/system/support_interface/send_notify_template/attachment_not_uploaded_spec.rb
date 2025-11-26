require 'rails_helper'

RSpec.describe 'Send notify template' do
  include DfESignInHelpers

  before do
    stub_notify_template_check
  end

  scenario 'Support user does not upload an attachment' do
    given_i_am_a_support_user
    when_i_navigate_to_settings
    and_i_click_on_send_notify_template
    then_i_see_the_send_notify_template_form

    when_i_complete_the_notify_template_form
    and_i_click_on_send
    then_i_see_an_error_for_not_uploading_a_distribution_list
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
    expect(page).to have_element(
      :li,
      text: 'Emails will only be sent once suitable and valid files have been provided.',
    )
    expect(page).to have_element(
      :li,
      text: 'Emails are sent in batches of 100 staggered over time, depending on the size of the distribution list.',
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
    attach_file 'Attachment', 'spec/fixtures/send_notify_template/hello_world.txt'
  end

  def and_i_click_on_send
    click_link_or_button 'Send'
  end

  def then_i_see_an_error_for_not_uploading_a_distribution_list
    within('.govuk-error-summary') do
      expect(page).to have_element(:h2, text: 'There is a problem', class: 'govuk-error-summary__title')
      expect(page).to have_element(:div, text: 'Upload a distribution list', class: 'govuk-error-summary__body')
    end
  end
end

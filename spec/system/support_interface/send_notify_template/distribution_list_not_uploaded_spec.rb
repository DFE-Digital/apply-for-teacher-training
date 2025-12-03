require 'rails_helper'

RSpec.describe 'Send notify template' do
  include DfESignInHelpers

  before do
    stub_notify_template_check
  end

  scenario 'Support user does not upload a distribution list' do
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
      click_link_or_button 'Send Notify template'
    end
  end

  def then_i_see_the_send_notify_template_form
    expect(page).to have_current_path('/support/settings/notify-template')
    expect(page).to have_title('Send Notify template - Settings - Support for Apply - GOV.UK')
    expect(page).to have_element(
      :h1,
      text: 'Send a GOV.UK Notify email with an attachment',
      class: 'govuk-heading-l',
    )
    expect(page).to have_element(
      :p,
      text: 'Use this to include an attachment in the emails you send through GOV.UK Notify.',
      class: 'govuk-body',
    )

    expect(page).to have_element(
      :h2,
      text: 'Save the document you want to include as an attachment',
      class: 'govuk-heading-m',
    )
    expect(page).to have_element(
      :li,
      text: 'Give your document a sensible name that is easy to understand. The file name will be visible in the email you send.',
    )
    expect(page).to have_element(:li, text: 'Include underscores between words in your file name, for example file_name.')
    expect(page).to have_element(:li, text: 'Your file name should be 100 characters or fewer.')

    expect(page).to have_element(
      :h2,
      text: 'Add a placeholder to the GOV.UK Notify template',
      class: 'govuk-heading-m',
    )
    expect(page).to have_element(:li, text: 'Sign in to GOV.UK Notify.')
    expect(page).to have_element(:li, text: 'Go to the Templates page and select the relevant email template.')
    expect(page).to have_element(:li, text: 'Select Edit.')
    expect(page).to have_element(
      :li,
      text: 'Add a placeholder to the email template using double brackets. For example: \'Download your file at: ((link_to_file))\'. This is your attachment.',
    )
    expect(page).to have_element(
      :li,
      text: 'Your email should also tell recipients how long the file will be available to download. 26 weeks is the standard time period.',
    )

    expect(page).to have_element(
      :h2,
      text: 'Create a distribution list',
      class: 'govuk-heading-m',
    )
    expect(page).to have_element(:li, text: 'The distribution list must be a .CSV file.')
    expect(page).to have_element(:li, text: 'The distribution list file must contain the column header \'Email address\'.')
    expect(page).to have_element(
      :li,
      text: 'You cannot include any other personalisation in your email or distribution list, for example ((first name)).',
    )

    expect(page).to have_element(
      :p,
      text: 'Emails are sent in batches of 100 staggered over time. The time taken to complete the send will depend on the size of your distribution list.',
      class: 'govuk-body',
    )

    expect(page).to have_field('Notify template ID', type: 'text')
    expect(page).to have_field('Distribution list', type: 'file')
    expect(page).to have_field('Attachment', type: 'file')
    expect(page).to have_button('Send email to distribution list')
  end

  def when_i_complete_the_notify_template_form
    fill_in 'Notify template ID', with: '123456'
    attach_file 'Attachment', 'spec/fixtures/send_notify_template/hello_world.txt'
  end

  def and_i_click_on_send
    click_link_or_button 'Send email to distribution list'
  end

  def then_i_see_an_error_for_not_uploading_a_distribution_list
    within('.govuk-error-summary') do
      expect(page).to have_element(:h2, text: 'There is a problem', class: 'govuk-error-summary__title')
      expect(page).to have_element(:div, text: 'Upload a distribution list', class: 'govuk-error-summary__body')
    end
  end
end

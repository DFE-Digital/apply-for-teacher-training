require 'rails_helper'

RSpec.feature 'Processing matching data from UCAS', sidekiq: true do
  include DfESignInHelpers

  scenario 'A download from UCAS is processed' do
    given_there_is_a_new_match
    and_there_is_a_previous_match_with_dual_application_we_emailed_about
    and_there_is_a_previous_match_with_no_changes
    and_ucas_has_uploaded_a_file_to_our_shared_folder

    a_file_download_check_is_logged { when_the_daily_download_runs }
    then_we_have_sent_email_to_the_provider_that_the_match_was_resolved_on_ucas
    then_we_have_sent_emails_about_dual_application_to_the_candidate_and_the_provider
    and_we_have_received_a_slack_message

    when_i_visit_the_ucas_matches_page_in_support
    then_the_new_match_is_created
    then_the_match_with_dual_application_shows_that_we_sent_the_initial_emails
    then_the_match_with_dual_application_withdrawn_from_ucas_shows_as_resolved_on_ucas

    when_i_click_on_the_new_match
    then_i_see_the_matching_info
    when_the_daily_download_runs_again
    then_nothing_has_happened
  end

  def given_there_is_a_new_match
    @not_previously_matched = Candidate.create_with(email_address: 'not_previously_matched@abc.com').find_or_create_by(id: 999213)
    @provider_user = create(:provider_user, :with_notifications_enabled)
    course = create(:course, code: 'XYZ', provider: create(:provider, code: 'XX', provider_users: [@provider_user]))
    course_option = create(:course_option, course: course)
    application_choice = create(:submitted_application_choice, course_option: course_option)
    create(:completed_application_form, candidate: @not_previously_matched, application_choices: [application_choice])
  end

  def and_there_is_a_previous_match_with_dual_application_we_emailed_about
    @previously_matched_changed = Candidate.create_with(email_address: 'previously_matched_changed@abc.com').find_or_create_by(id: 99944)
    @provider_user1 = create(:provider_user, :with_notifications_enabled)
    course = create(:course, code: 'LMN', provider: create(:provider, code: '2FF', provider_users: [@provider_user1]))
    course_option = create(:course_option, course: course)
    application_choice = create(:submitted_application_choice, course_option: course_option)
    withdrawn_from_ucas_application_form = create(:completed_application_form, candidate: @previously_matched_changed, application_choices: [application_choice])
    create(:ucas_match,
           application_form: withdrawn_from_ucas_application_form,
           matching_data: [{ 'Scheme' => 'B', 'Apply candidate ID' => '99944', 'Provider code' => '2FF', 'Course code' => 'LMN', 'Offers' => '1', 'Withdrawns' => '.', 'Trackable applicant key' => 'ABC99944DEF' }],
           action_taken: 'initial_emails_sent',
           candidate_last_contacted_at: 1.business_days.before(Time.zone.now))
  end

  def and_there_is_a_previous_match_with_no_changes
    @previously_matched_unchanged = Candidate.create_with(email_address: 'previously_matched_unchanged@abc.com').find_or_create_by(id: 99957)
    course = create(:course, code: 'UVW', provider: create(:provider, code: '1EP'))
    course_option = create(:course_option, course: course)
    application_choice = create(:submitted_application_choice, course_option: course_option)
    application_form = create(:completed_application_form, candidate: @previously_matched_unchanged, application_choices: [application_choice])
    create(:ucas_match,
           application_form: application_form,
           matching_data: [{ 'Scheme' => 'D', 'Apply candidate ID' => '99957', 'Provider code' => '1EP', 'Course code' => 'UVW', 'Offers' => '.', 'Withdrawns' => '.', 'Trackable applicant key' => 'ABC99957DEFпїЅ' }])
  end

  def and_ucas_has_uploaded_a_file_to_our_shared_folder
    stub_request(:post, 'https://transfer.ucasenvironments.com/api/v1/token')
      .to_return(
        body: { access_token: '123456789' }.to_json,
      )

    stub_request(:get, 'https://transfer.ucasenvironments.com/api/v1/folders/691078359/files?sortField=uploadStamp&sortDirection=descending')
      .with(
        headers: {
          'Authorization' => 'Bearer 123456789',
        },
      )
      .to_return(body: { items: [{ id: '321' }] }.to_json)

    stub_request(:get, 'https://transfer.ucasenvironments.com/api/v1/folders/691078359/files/321/download')
      .with(
        headers: {
          'Authorization' => 'Bearer 123456789',
        },
      )
      .to_return(status: 302, headers: { 'Location' => 'https://example.org/file.zip' })

    File.delete('spec/system/ucas_matching/matching_data_example.zip') if File.exist?('spec/system/ucas_matching/matching_data_example.zip')

    Archive::Zip.archive(
      'spec/system/ucas_matching/matching_data_example.zip',
      'spec/system/ucas_matching/matching_data_example.csv',
      encryption_codec: Archive::Zip::Codec::TraditionalEncryption,
      password: ENV.fetch('UCAS_DOWNLOAD_ZIP_PASSWORD'),
    )

    stub_request(:get, 'https://example.org/file.zip')
      .with(
        headers: {
          'Authorization' => 'Bearer 123456789',
        },
      )
      .to_return(body: File.new('spec/system/ucas_matching/matching_data_example.zip'))
  end

  def when_the_daily_download_runs
    @latest_exception = nil
    UCASMatching::ProcessMatchingData.new.perform
  rescue UCASMatching::APIError => e
    @latest_exception = e
  end

  def a_file_download_check_is_logged(&block)
    allow(UCASMatching::FileDownloadCheck).to receive(:set_last_sync)
    block.call
    expect(UCASMatching::FileDownloadCheck).to have_received(:set_last_sync)
  end

  def and_we_have_received_a_slack_message
    expect_slack_message_with_text('It contained 1 new match, 1 updated match, and 1 match we’ve already seen.')
    expect_slack_message_with_text('We have 1 match requiring action.')
  end

  def then_we_have_sent_email_to_the_provider_that_the_match_was_resolved_on_ucas
    provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == @provider_user1.email_address }
    expect(provider_email.subject).to include 'Duplicate application withdrawn'
  end

  def then_we_have_sent_emails_about_dual_application_to_the_candidate_and_the_provider
    candidate_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == @not_previously_matched.email_address }
    expect(candidate_email.subject).to include 'Withdraw your duplicate application'

    provider_email = ActionMailer::Base.deliveries.find { |e| e.header['to'].value == @provider_user.email_address }
    expect(provider_email.subject).to include 'Duplicate application identified'
  end

  def when_i_visit_the_ucas_matches_page_in_support
    sign_in_as_support_user
    visit support_interface_ucas_matches_path
  end

  def then_the_new_match_is_created
    expect(page).to have_content @not_previously_matched.email_address
    expect(page).to have_content 'No action taken'
  end

  def then_the_match_with_dual_application_shows_that_we_sent_the_initial_emails
    expect(page).to have_content 'Initial emails sent'
  end

  def then_the_match_with_dual_application_withdrawn_from_ucas_shows_as_resolved_on_ucas
    expect(page).to have_content 'Resolved on UCAS'
  end

  def when_i_click_on_the_new_match
    click_on @not_previously_matched.email_address
  end

  def then_i_see_the_matching_info
    expect(page).to have_content '999213'
    expect(page).to have_content 'XX'
    expect(page).to have_content 'XYZ'
  end

  def when_the_daily_download_runs_again
    allow(Rails.logger).to receive(:info)
    @latest_exception = nil
    UCASMatching::ProcessMatchingData.new.perform
  rescue UCASMatching::APIError => e
    @latest_exception = e
  end

  def then_nothing_has_happened
    expect(Rails.logger).to have_received(:info).with('Skipping file with ID 321 - we’ve already processed it')
  end
end

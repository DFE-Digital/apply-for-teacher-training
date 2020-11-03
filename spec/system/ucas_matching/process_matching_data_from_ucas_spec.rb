require 'rails_helper'

RSpec.feature 'Processing matching data from UCAS', sidekiq: true do
  include DfESignInHelpers

  scenario 'A download from UCAS is processed' do
    given_there_is_a_newly_matched_candidate
    and_there_is_a_previously_matched_candidate_with_new_data
    and_there_is_a_previously_matched_candidate_with_no_changes
    and_ucas_has_uploaded_a_file_to_our_shared_folder

    when_the_daily_download_runs
    then_we_have_received_a_slack_message

    when_i_visit_the_ucas_matches_page_in_support
    then_the_new_match_is_created
    and_the_existing_match_is_updated
    and_the_unchanged_existing_match_is_left_alone

    when_i_click_on_a_match
    then_i_see_the_matching_info
    when_i_mark_the_match_as_processed
    then_the_match_is_processed

    when_the_daily_download_runs_again
    then_nothing_has_happened
  end

  def given_there_is_a_newly_matched_candidate
    @not_previously_matched = Candidate.create_with(email_address: 'not_previously_matched@abc.com').find_or_create_by(id: 999213)
    course = create(:course, code: 'XYZ', provider: create(:provider, code: 'XX'))
    course_option = create(:course_option, course: course)
    application_choice = create(:submitted_application_choice, course_option: course_option)
    create(:completed_application_form, candidate: @not_previously_matched, application_choices: [application_choice])
  end

  def and_there_is_a_previously_matched_candidate_with_new_data
    @previously_matched_changed = Candidate.create_with(email_address: 'previously_matched_changed@abc.com').find_or_create_by(id: 99944)
    course1 = create(:course, code: 'LMN', provider: create(:provider, code: '2FF'))
    course_option1 = create(:course_option, course: course1)
    application_choice1 = create(:submitted_application_choice, course_option: course_option1)
    course2 = create(:course, code: 'OPQ', provider: create(:provider, code: 'D87'))
    course_option2 = create(:course_option, course: course2)
    application_choice2 = create(:submitted_application_choice, course_option: course_option2)
    course3 = create(:course, code: 'RST', provider: create(:provider, code: 'L06'))
    course_option3 = create(:course_option, course: course3)
    application_choice3 = create(:submitted_application_choice, course_option: course_option3)
    application_form = create(:completed_application_form, candidate: @previously_matched_changed, application_choices: [application_choice1, application_choice2, application_choice3])
    create(:ucas_match, matching_state: 'processed', application_form: application_form, scheme: 'U', ucas_status: :offer)
  end

  def and_there_is_a_previously_matched_candidate_with_no_changes
    @previously_matched_unchanged = Candidate.create_with(email_address: 'previously_matched_unchanged@abc.com').find_or_create_by(id: 99957)
    course = create(:course, code: 'UVW', provider: create(:provider, code: '1EP'))
    course_option = create(:course_option, course: course)
    application_choice = create(:submitted_application_choice, course_option: course_option)
    application_form = create(:completed_application_form, candidate: @previously_matched_unchanged, application_choices: [application_choice])
    create(:ucas_match,
           matching_state: 'processed',
           application_form: application_form,
           scheme: 'B',
           ucas_status: :offer,
           matching_data: [{ 'Apply candidate ID' => '99957', 'Provider code' => '1EP', 'Course code' => 'UVW' }])
  end

  def and_ucas_has_uploaded_a_file_to_our_shared_folder
    stub_request(:post, 'https://transfer.ucasenvironments.com/api/v1/token')
      .to_return(
        body: { access_token: '123456789' }.to_json,
      )

    stub_request(:get, 'https://transfer.ucasenvironments.com/api/v1/folders/691078359/files')
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

  def then_we_have_received_a_slack_message
    expect_slack_message_with_text('It contained 1 new match, 1 updated match, and 1 match we’ve already seen.')
  end

  def when_i_visit_the_ucas_matches_page_in_support
    sign_in_as_support_user
    visit support_interface_ucas_matches_path
  end

  def then_the_new_match_is_created
    expect(page).to have_content @not_previously_matched.email_address
    expect(page).to have_content 'New match'
  end

  def and_the_existing_match_is_updated
    expect(page).to have_content @previously_matched_changed.email_address
    expect(page).to have_content 'Updated'
  end

  def and_the_unchanged_existing_match_is_left_alone
    expect(page).to have_content @previously_matched_unchanged.email_address
    expect(page).to have_content 'Processed'
  end

  def when_i_click_on_a_match
    click_on @not_previously_matched.email_address
  end

  def then_i_see_the_matching_info
    expect(page).to have_content '999213'
    expect(page).to have_content 'XX'
    expect(page).to have_content 'XYZ'
  end

  def when_i_mark_the_match_as_processed
    click_on 'Mark as processed'
  end

  def then_the_match_is_processed
    expect(page).to have_content 'Match marked as processed'
    expect(page).to have_content 'Processed'
  end

  def when_the_daily_download_runs_again
    allow(Rails.logger).to receive(:info)
    @latest_exception = nil
    UCASMatching::ProcessMatchingData.new.perform
  rescue UCASMatching::APIError => e
    @latest_exception = e
  end

  def then_nothing_has_happened
    expect(Rails.logger).to have_received(:info).with("Skipping file with ID 321 - we've already processed it")
  end
end

require 'rails_helper'

RSpec.feature 'See UCAS matches' do
  include DfESignInHelpers

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  scenario 'Support agent visits UCAS matches pages', sidekiq: true do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_there_are_ucas_matches_in_the_system

    when_i_go_to_ucas_matches_page
    then_i_should_see_list_of_ucas_matches
    and_i_should_see_which_ucas_matches_need_action

    when_i_filter_by_recruitment_cycle
    then_i_only_see_applications_for_that_recruitment_cycle
    and_i_expect_the_relevant_recruitment_cycle_tags_to_be_visible

    when_i_follow_the_link_to_ucas_match_for_a_candidate
    then_i_should_see_ucas_match_summary

    when_i_go_to_ucas_matches_page
    when_i_filter_by_action_needed
    then_i_only_see_matches_that_need_action
    and_i_expect_the_relevant_action_needed_tags_to_be_visible

    when_i_follow_the_link_to_ucas_match_for_a_candidate_which_needs_an_action
    then_i_see_that_i_need_to 'Send initial emails'
    given_the_send_ucas_matches_emails_worker_run
    then_i_see_last_performed_action_is 'sent the initial emails'

    given_five_working_days_passed
    when_i_visit_the_page_again
    then_i_see_that_i_need_to 'Send a reminder email'
    given_the_send_ucas_matches_emails_worker_run
    then_i_see_last_performed_action_is 'sent the reminder emails'

    given_five_more_working_days_passed
    when_i_visit_the_page_again
    then_i_see_that_i_need_to 'Request withdrawal from UCAS'
    and_when_i_click 'Confirm withdrawal from UCAS was requested'

    then_i_see_last_performed_action_is 'requested withdrawal from UCAS'

    when_i_go_to_ucas_matches_page
    and_when_i_filter_by_last_action_taken
    then_i_only_see_matches_with_selected_action_taken
    and_i_expect_the_relevant_action_taken_tags_to_be_visible
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def given_the_send_ucas_matches_emails_worker_run
    Sidekiq::Worker.clear_all
    UCASMatches::SendUCASMatchEmails.perform_async
    Sidekiq::Worker.drain_all
    visit current_path
  end

  def and_there_are_applications_in_the_system
    @candidate = create(:candidate)
    @course1 = create(:course)
    course_option1 = create(:course_option, course: @course1)
    application_choice1 = create(:application_choice, :with_offer, course_option: course_option1)
    @course2 = create(:course)
    course_option2 = create(:course_option, course: @course2)
    application_choice2 = create(:submitted_application_choice, course_option: course_option2)
    @application_form = create(:application_form, candidate: @candidate, application_choices: [application_choice1, application_choice2])
    @candidate2 = create(:candidate)
    @course3 = create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year)
    course_option3 = create(:course_option, course: @course3)
    application_choice3 = create(:application_choice, :with_offer, course_option: course_option3)
    @application_form2 = create(:application_form, candidate: @candidate2, application_choices: [application_choice3], recruitment_cycle_year: RecruitmentCycle.previous_year)
  end

  def and_there_are_ucas_matches_in_the_system
    trackable_applicant_id = '0F8FB8240C73AB94'
    ucas_matching_data =
      {
        'Scheme' => 'B',
        'Apply candidate ID' => @candidate.id.to_s,
        'Course code' => @course1.code.to_s,
        'Provider code' => @course1.provider.code.to_s,
        'Withdrawns' => '1',
        'Trackable applicant key' => trackable_applicant_id,
      }
    dfe_matching_data =
      {
        'Scheme' => 'D',
        'Apply candidate ID' => @candidate.id.to_s,
        'Course code' => @course2.code.to_s,
        'Provider code' => @course2.provider.code.to_s,
        'Trackable applicant key' => trackable_applicant_id,
      }
    invalid_dfe_matching_data =
      {
        'Scheme' => 'D',
        'Apply candidate ID' => @candidate.id.to_s,
        'Course code' => 'DOES_NOT_EXIST',
        'Provider code' => @course2.provider.code.to_s,
        'Trackable applicant key' => trackable_applicant_id,
      }

    create(:ucas_match, application_form: @application_form, matching_data: [ucas_matching_data, dfe_matching_data, invalid_dfe_matching_data])
    create(:ucas_match, scheme: %w[B], ucas_status: :offer, application_form: @application_form2)
  end

  def when_i_go_to_ucas_matches_page
    visit support_interface_ucas_matches_path
  end

  def then_i_should_see_list_of_ucas_matches
    expect(page).to have_content 'No action taken'
    expect(page).to have_content @candidate.email_address
  end

  def and_i_should_see_which_ucas_matches_need_action
    expect(page).to have_content 'No action taken Action needed'
    expect(page).to have_content 'Invalid data'
  end

  def when_i_filter_by_recruitment_cycle
    find(:css, "#years-#{RecruitmentCycle.current_year}").set(true)
    click_button('Apply filters')
  end

  def then_i_only_see_applications_for_that_recruitment_cycle
    expect(page).not_to have_content(@candidate2.email_address)
  end

  def and_i_expect_the_relevant_recruitment_cycle_tags_to_be_visible
    tag_text = "#{RecruitmentCycle.current_year - 1} to #{RecruitmentCycle.current_year}"
    expect(page).to have_css('.moj-filter-tags', text: tag_text)
  end

  def when_i_follow_the_link_to_ucas_match_for_a_candidate
    click_link @candidate.email_address
  end

  def then_i_should_see_ucas_match_summary
    within('main dl div:eq(7)') do
      expect(page).to have_content 'Trackable applicant key'
      expect(page).to have_content '0F8FB8240C73AB94'
    end

    expect(page).to have_content 'Matched courses'
    within('tbody tr:eq(1)') do
      expect(page).to have_content(@course1.code)
      expect(page).to have_content("#{@course1.name} – #{@course1.provider.name}")
      expect(page).to have_content('Withdrawn')
      expect(page).to have_content('Offer made')
    end
    within('tbody tr:eq(2)') do
      expect(page).to have_content(@course2.code)
      expect(page).to have_content("#{@course2.name} – #{@course2.provider.name}")
      expect(page).to have_content('N/A')
      expect(page).to have_content('Awaiting provider decision')
    end
    within('tbody tr:eq(3)') do
      expect(page).to have_content('DOES_NOT_EXIST')
      expect(page).to have_content("Missing course name – #{@course2.provider.name}")
      expect(page).to have_content('N/A')
      expect(page).to have_content('Invalid data')
    end

    expect(page).to have_content('This applicant has applied to the same course on both services.')
  end

  def when_i_filter_by_action_needed
    find(:css, '#action_needed-yes').set(true)
    click_button('Apply filters')
  end

  def then_i_only_see_matches_that_need_action
    expect(page).to have_content(@candidate2.email_address)
    expect(page).not_to have_content(@candidate.email_address)
  end

  def and_i_expect_the_relevant_action_needed_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Yes')
  end

  def when_i_follow_the_link_to_ucas_match_for_a_candidate_which_needs_an_action
    click_link @candidate2.email_address
  end

  def then_i_see_that_i_need_to(action_to_take)
    expect(page).to have_text "Action needed #{action_to_take}"
  end

  def and_when_i_click(button_text)
    click_button button_text
  end

  def then_i_see_last_performed_action_is(action)
    expect(page).to have_content 'No action required'
    expect(page).to have_content "We #{action}"
  end

  def given_five_working_days_passed
    Timecop.safe_mode = false
    Timecop.travel(5.business_days.from_now)
  ensure
    Timecop.safe_mode = true
  end

  def given_five_more_working_days_passed
    Timecop.safe_mode = false
    Timecop.travel(10.business_days.from_now)
  ensure
    Timecop.safe_mode = true
  end

  def when_i_visit_the_page_again
    visit current_path
    given_i_am_a_support_user
  end

  def and_when_i_filter_by_last_action_taken
    find(:css, '#action_taken-ucas_withdrawal_requested').set(true)
    click_button('Apply filters')
  end

  def then_i_only_see_matches_with_selected_action_taken
    expect(page).to have_content(@candidate2.email_address)
    expect(page).not_to have_content(@candidate.email_address)
  end

  def and_i_expect_the_relevant_action_taken_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'UCAS withdrawal requested')
  end
end

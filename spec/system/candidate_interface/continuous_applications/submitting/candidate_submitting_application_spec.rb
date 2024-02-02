require 'rails_helper'

RSpec.feature 'Candidate submits the application' do
  include CandidateHelper

  scenario 'Candidate with a completed application' do
    given_i_am_signed_in

    when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice
    and_i_continue_with_my_application

    when_i_save_as_draft
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_still_unsubmitted
    and_i_continue_with_my_application

    when_i_click_to_review_my_application
    then_i_see_a_interruption_page_for_personal_statement

    when_i_continue_without_editing
    then_i_should_see_the_review_and_submit_page
    when_i_go_back

    when_i_click_to_review_my_application
    then_i_see_a_interruption_page_for_personal_statement

    when_i_edit_my_personal_statement
    and_i_continue_with_my_application
    and_i_choose_to_submit
    then_i_can_see_my_application_has_been_successfully_submitted
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_submitted
    then_i_can_see_my_submitted_application
    and_i_can_see_i_have_three_choices_left
    # and_i_receive_an_email_confirmation

    when_i_click_view_application
    then_i_can_review_my_submitted_application

    when_i_go_back

    when_i_have_three_further_draft_choices
    then_i_can_no_longer_add_more_course_choices

    when_i_submit_one_of_my_draft_applications
    then_i_still_cannot_add_course_choices

    when_one_of_my_applications_becomes_inactive
    then_i_am_able_to_add_another_choice
  end

  scenario 'Candidate with a primary application missing the science GCSE' do
    given_i_am_signed_in

    when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice
    when_i_have_not_completed_science_gcse
    and_i_continue_with_my_application

    then_i_should_see_an_error_message_that_i_should_complete_the_science_gcse

    when_i_click_on_the_error_message
    then_i_should_be_on_science_gcse_section
  end

  scenario 'Candidate with a primary application missing the science GCSE and missing other sections' do
    given_i_am_signed_in

    when_i_have_an_incomplete_application_and_have_added_primary_as_a_course_choice
    when_i_have_not_completed_science_gcse
    and_i_continue_with_my_application

    then_i_should_see_an_error_message_that_i_should_complete_the_science_gcse

    when_i_click_on_the_error_message
    then_i_should_be_on_your_details_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice
    given_i_have_a_primary_course_choice(application_form_completed: true)
  end

  def when_i_have_an_incomplete_application_and_have_added_primary_as_a_course_choice
    given_i_have_a_primary_course_choice(application_form_completed: false)
  end

  def given_i_have_a_primary_course_choice(application_form_completed:)
    completed_section_trait = application_form_completed.present? ? :completed : :minimum_info

    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(
      :site,
      name: 'Main site',
      code: '-',
      provider: @provider,
      address_line1: 'Gorse SCITT',
      address_line2: 'C/O The Bruntcliffe Academy',
      address_line3: 'Bruntcliffe Lane',
      address_line4: 'MORLEY, lEEDS',
      postcode: 'LS27 0LZ',
    )
    @course = create(:course, :open_on_apply, name: 'Primary', code: '2XT2', provider: @provider)
    @course_option = create(:course_option, site:, course: @course)
    current_candidate.application_forms.delete_all
    current_candidate.application_forms << build(:application_form, completed_section_trait, becoming_a_teacher: 'I want to teach')
    @application_choice = create(:application_choice, :unsubmitted, course_option: @course_option, application_form: current_candidate.current_application)
  end

  def when_i_have_not_completed_science_gcse
    @application_choice.application_form.update!(science_gcse_completed: false)
  end

  def and_i_continue_with_my_application
    visit candidate_interface_continuous_applications_choices_path
    click_link_or_button 'Continue application', match: :first
  end

  def and_i_review_my_application
    visit candidate_interface_continuous_applications_choices_path
    click_link_or_button 'View application', match: :first
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  def when_i_save_as_draft
    click_link_or_button 'Save as draft'
  end

  def when_i_choose_to_submit
    when_i_click_to_review_my_application
    when_i_click_to_submit_my_application
  end
  alias_method :and_i_choose_to_submit, :when_i_choose_to_submit

  def and_my_application_is_still_unsubmitted
    expect(@application_choice.reload).to be_unsubmitted
  end

  def and_i_can_see_my_course_choices
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Primary (2XT2)'
  end

  def then_i_should_see_an_error_message_that_i_should_choose_an_option
    expect(page).to have_content 'There is a problem'
    expect(page).to have_content 'Select if you want to submit your application or save it as a draft'
  end

  def then_i_should_see_an_error_message_that_i_should_complete_the_science_gcse
    expect(page).to have_content 'To apply for a Primary course, you need a GCSE in science at grade 4 (C) or above, or equivalent.'
    expect(page).to have_content 'Your application will be saved as a draft while you finish adding your details.'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application submitted'
  end

  def and_i_am_redirected_to_the_application_dashboard
    expect(page).to have_content t('page_titles.application_dashboard')
    expect(page).to have_content 'Gorse SCITT'
  end

  def when_i_click_view_application
    click_link_or_button 'View application', match: :first
  end

  def and_my_application_is_submitted
    expect(@application_choice.reload).to be_awaiting_provider_decision
  end

  def then_i_can_see_my_submitted_application
    expect(@current_candidate.current_application.application_choices).to contain_exactly(@application_choice)
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Primary (2XT2)'
    expect(page).to have_content 'PGCE with QTS full time'
    expect(page).to have_content 'Awaiting decision'
  end

  def then_i_can_review_my_submitted_application
    expect(@current_candidate.current_application.application_choices).to contain_exactly(@application_choice)
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Awaiting decision'
    expect(page).to have_content @application_choice.sent_to_provider_at.to_fs(:govuk_date_and_time)
    expect(page).to have_content 'Primary (2XT2)'
    expect(page).to have_content 'Full time'
    expect(page).to have_content 'Main site'
    expect(page).to have_content @application_choice.personal_statement
  end

  def and_i_can_see_i_have_three_choices_left
    expect(page).to have_content 'You can add 3 more applications.'
  end

  def when_i_have_three_further_draft_choices
    @current_candidate.current_application.application_choices << build_list(:application_choice, 3, :unsubmitted)
  end

  def then_i_can_no_longer_add_more_course_choices
    visit current_path
    expect(page).to have_content 'You cannot add any more applications.'
    expect(page).to have_content 'You can add more applications if'
    expect(page).to have_content 'one of your submitted applications becomes unsuccessful'
    expect(page).to have_content 'you withdraw or remove an application'
  end
  alias_method :then_i_still_cannot_add_course_choices, :then_i_can_no_longer_add_more_course_choices

  def when_i_submit_one_of_my_draft_applications
    click_link_or_button 'Continue application', match: :first
    when_i_click_to_review_my_application
    when_i_click_to_submit_my_application
  end

  def when_i_click_to_review_my_application
    click_link_or_button 'Review application'
  end

  def when_i_click_to_submit_my_application
    click_link_or_button 'Confirm and submit application'
  end

  def when_one_of_my_applications_becomes_inactive
    @current_candidate.current_application.application_choices.where(status: 'awaiting_provider_decision').first.update!(status: 'inactive')
  end

  def then_i_am_able_to_add_another_choice
    visit current_path
    expect(page).to have_content 'You can add 1 more application.'
  end

  def when_i_go_back
    click_link_or_button 'Back'
  end

  def then_i_see_a_interruption_page_for_personal_statement
    expect(page).to have_content 'Your personal statement is 4 words.'
  end

  def when_i_continue_without_editing
    click_link_or_button 'Continue without editing'
  end

  def then_i_should_see_the_review_and_submit_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_course_review_and_submit_path(@application_choice.id))
  end

  def when_i_edit_my_personal_statement
    click_link_or_button 'Edit your personal statement'
    fill_in 'candidate_interface_becoming_a_teacher_form[becoming_a_teacher]', with: Faker::Lorem.sentence(word_count: 500)
    click_link_or_button t('continue')
  end

  def when_i_click_on_the_error_message
    click_link_or_button 'Add your science GCSE grade (or equivalent)'
  end

  def then_i_should_be_on_science_gcse_section
    expect(page).to have_current_path(candidate_interface_gcse_details_new_type_path(subject: 'science'))
  end

  def then_i_should_be_on_your_details_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_details_path)
  end
end

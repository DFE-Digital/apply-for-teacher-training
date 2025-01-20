require 'rails_helper'

RSpec.describe 'Candidate with no right to work or study' do
  include CandidateHelper

  before do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options
  end

  scenario 'when candidate did not add their nationality yet neither right to work study' do
    and_i_add_a_course_that_can_not_sponsor_student_visa
    then_i_do_not_see_an_error_message_that_the_course_does_not_sponsor_visa
  end

  scenario 'when submit a course that can not sponsor student visa' do
    when_i_have_completed_my_foreign_application
    and_i_add_a_course_that_can_not_sponsor_student_visa
    then_i_see_an_error_message_that_the_course_does_not_sponsor_visa
  end

  scenario 'when submit a course that can not sponsor skilled worker visa' do
    when_i_have_completed_my_foreign_application
    and_i_add_a_course_that_can_not_sponsor_skilled_worker
    then_i_see_an_error_message_that_the_course_does_not_sponsor_visa
  end

  scenario 'when submit a course that can sponsor student visa' do
    when_i_have_completed_my_foreign_application
    and_i_add_a_course_that_can_sponsor_student_visa
    then_i_do_not_see_an_error_message_that_the_course_does_not_sponsor_visa
    and_i_submit_the_application
    then_i_can_see_my_application_has_been_successfully_submitted
  end

  scenario 'when submit a course that can sponsor skilled worker visa' do
    when_i_have_completed_my_foreign_application
    and_i_add_a_course_that_can_sponsor_skilled_worker
    then_i_do_not_see_an_error_message_that_the_course_does_not_sponsor_visa
    and_i_submit_the_application
    then_i_can_see_my_application_has_been_successfully_submitted
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course_can_sponsor_student_visa = create(
      :course,
      :open,
      name: 'Modern Languages',
      code: 'S397',
      provider: @provider,
      can_sponsor_skilled_worker_visa: false,
      can_sponsor_student_visa: true,
      funding_type: 'fee',
    )
    @course_can_not_sponsor_student_visa = create(
      :course,
      :open,
      name: 'English',
      code: 'Q3X1',
      provider: @provider,
      can_sponsor_skilled_worker_visa: false,
      can_sponsor_student_visa: false,
      funding_type: 'fee',
    )
    @course_can_sponsor_skilled_worker_visa = create(
      :course,
      :open,
      name: 'History',
      code: 'V1X1',
      provider: @provider,
      can_sponsor_skilled_worker_visa: true,
      can_sponsor_student_visa: false,
      funding_type: 'salary',
    )
    @course_can_not_sponsor_skilled_worker_visa = create(
      :course,
      :open,
      name: 'Physics',
      code: 'F3X1',
      provider: @provider,
      can_sponsor_skilled_worker_visa: false,
      can_sponsor_student_visa: false,
      funding_type: 'salary',
    )
    create(:course_option, course: @course_can_sponsor_student_visa)
    create(:course_option, course: @course_can_not_sponsor_student_visa)
    create(:course_option, course: @course_can_sponsor_skilled_worker_visa)
    create(:course_option, course: @course_can_not_sponsor_skilled_worker_visa)
  end

  def when_i_have_completed_my_foreign_application
    @application_form = create(
      :application_form,
      :completed,
      :with_degree,
      candidate: current_candidate,
      first_nationality: 'Indian',
      second_nationality: nil,
      right_to_work_or_study: 'no',
      efl_completed: true,
    )
  end

  def and_i_add_a_course_that_can_not_sponsor_student_visa
    when_i_choose_a_provider
    choose @course_can_not_sponsor_student_visa.name
    and_i_click_continue
  end

  def and_i_add_a_course_that_can_not_sponsor_skilled_worker
    when_i_choose_a_provider
    choose @course_can_not_sponsor_skilled_worker_visa.name
    and_i_click_continue
  end

  def and_i_add_a_course_that_can_sponsor_student_visa
    when_i_choose_a_provider
    choose @course_can_sponsor_student_visa.name
    and_i_click_continue
  end

  def and_i_add_a_course_that_can_sponsor_skilled_worker
    when_i_choose_a_provider
    choose @course_can_sponsor_skilled_worker_visa.name
    and_i_click_continue
  end

  def when_i_choose_a_provider
    visit candidate_interface_details_path
    click_link_or_button 'Your application'
    click_link_or_button 'Add application'
    choose 'Yes, I know where I want to apply'
    and_i_click_continue
    select 'Gorse SCITT (1N1)'
    and_i_click_continue
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  def then_i_see_an_error_message_that_the_course_does_not_sponsor_visa
    expect(page).to have_content('Visa sponsorship is not available for this course.')
    expect(page).to have_content('Find a course that has visa sponsorship')
  end

  def then_i_do_not_see_an_error_message_that_the_course_does_not_sponsor_visa
    expect(page).to have_no_content('Visa sponsorship is not available for this course.')
    expect(page).to have_no_content('Find a course that has visa sponsorship')
  end

  def and_i_submit_the_application
    expect(page).to have_content('Review application')
    when_i_click_to_review_my_application
    when_i_click_to_submit_my_application
  end

  def when_i_click_to_review_my_application
    click_link_or_button 'Review application'
  end

  def when_i_click_to_submit_my_application
    click_link_or_button 'Confirm and submit application'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application submitted'

    expect(@application_form.application_choices.first).to be_awaiting_provider_decision
  end
end

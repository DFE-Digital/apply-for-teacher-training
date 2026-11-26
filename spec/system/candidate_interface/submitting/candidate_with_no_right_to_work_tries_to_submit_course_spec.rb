require 'rails_helper'

RSpec.describe 'Candidate with no right to work or study', :with_cache do
  include CandidateHelper
  include DfE::Bigquery::TestHelper

  before do
    stub_bigquery_non_disclosure_trainee_withdrawals_request
    given_i_am_signed_in_with_one_login
    and_there_are_course_options
  end

  scenario 'when candidate did not add their nationality yet neither right to work study' do
    and_i_add_a_course_that_cannot_sponsor_student_visa
    then_i_do_not_see_an_error_message_that_the_course_does_not_sponsor_visa
  end

  scenario 'when submit a course that cannot sponsor student visa' do
    when_i_have_completed_my_foreign_application
    and_i_add_a_course_that_cannot_sponsor_student_visa
    then_i_see_an_error_message_that_the_course_does_not_sponsor_visa
  end

  scenario 'when submit a course that cannot sponsor skilled worker visa' do
    when_i_have_completed_my_foreign_application
    and_i_add_a_course_that_cannot_sponsor_skilled_worker
    then_i_see_an_error_message_that_the_course_does_not_sponsor_visa
  end

  scenario 'when submit a course that can sponsor student visa' do
    when_i_have_completed_my_foreign_application
    and_i_add_a_course_that_can_sponsor_student_visa
    then_i_do_not_see_an_error_message_that_the_course_does_not_sponsor_visa
    and_i_submit_the_international_application
    then_i_can_see_my_application_has_been_successfully_submitted
  end

  scenario 'when submit a course that can sponsor skilled worker visa' do
    when_i_have_completed_my_foreign_application
    and_i_add_a_course_that_can_sponsor_skilled_worker
    then_i_do_not_see_an_error_message_that_the_course_does_not_sponsor_visa
    and_i_submit_the_international_application
    then_i_can_see_my_application_has_been_successfully_submitted
  end

  scenario 'when i have a skilled worker visa and course does not sponsor' do
    when_i_complete_an_application_with_skilled_worker_visa
    and_i_add_a_course_that_cannot_sponsor_skilled_worker
    then_i_see_the_visa_may_not_cover_course_interruption

    when_i_click_on_continue
    then_see_the_visa_explanation_form_page

    when_i_select_i_expect_to_extend_my_current_visa
    and_i_click_on_continue
    then_i_see_an_error_message_that_the_course_does_not_sponsor_visa
  end

  scenario 'when i have a student visa and course does not sponsor' do
    when_i_complete_an_application_with_student_visa
    and_i_add_a_course_that_cannot_sponsor_student_visa
    then_i_see_the_visa_may_not_cover_course_interruption

    when_i_click_on_continue
    then_see_the_visa_explanation_form_page

    when_i_select_i_expect_to_extend_my_current_visa
    and_i_click_on_continue
    then_i_see_an_error_message_that_the_course_does_not_sponsor_visa
  end

  scenario 'when I have a student visa and the course I select sponsors visas' do
    when_i_complete_an_application_with_student_visa
    and_i_add_a_course_that_can_sponsor_student_visa
    then_i_see_the_visa_may_not_cover_course_interruption_for_a_course_sponsoring_visas

    when_i_click_on_continue
    then_see_the_visa_explanation_form_page

    when_i_select_i_expect_to_extend_my_current_visa
    and_i_click_on_continue
    then_i_do_not_see_an_error_message_that_the_course_does_not_sponsor_visa
    and_i_submit_the_international_application
    then_i_can_see_my_application_has_been_successfully_submitted
  end

private

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
    @course_cannot_sponsor_student_visa = create(
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
    @course_cannot_sponsor_skilled_worker_visa = create(
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
    create(:course_option, course: @course_cannot_sponsor_student_visa)
    create(:course_option, course: @course_can_sponsor_skilled_worker_visa)
    create(:course_option, course: @course_cannot_sponsor_skilled_worker_visa)
  end

  def when_i_have_completed_my_foreign_application
    current_candidate.application_forms.destroy_all

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

  def when_i_complete_an_application_with_skilled_worker_visa
    current_candidate.application_forms.destroy_all

    @application_form = create(
      :application_form,
      :completed,
      :with_degree,
      candidate: current_candidate,
      first_nationality: 'Indian',
      second_nationality: nil,
      right_to_work_or_study: 'yes',
      immigration_status: 'skilled_worker_visa',
      efl_completed: true,
    )
  end

  def when_i_complete_an_application_with_student_visa
    current_candidate.application_forms.destroy_all

    @application_form = create(
      :application_form,
      :completed,
      :with_degree,
      candidate: current_candidate,
      first_nationality: 'Indian',
      second_nationality: nil,
      right_to_work_or_study: 'yes',
      immigration_status: 'student_visa',
      efl_completed: true,
    )
  end

  def and_i_add_a_course_that_cannot_sponsor_student_visa
    when_i_choose_a_provider
    choose @course_cannot_sponsor_student_visa.name
    and_i_click_continue
  end

  def and_i_add_a_course_that_cannot_sponsor_skilled_worker
    when_i_choose_a_provider
    choose @course_cannot_sponsor_skilled_worker_visa.name
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
    expect(page).to have_text('Visa sponsorship is not available for this course.')
    expect(page).to have_text('Find a course that has visa sponsorship')
  end

  def then_i_do_not_see_an_error_message_that_the_course_does_not_sponsor_visa
    expect(page).to have_no_text('Visa sponsorship is not available for this course.')
    expect(page).to have_no_text('Find a course that has visa sponsorship')
  end

  def and_i_submit_the_application
    expect(page).to have_text('Review application')
    when_i_click_to_review_my_application
    when_i_click_to_submit_my_application
  end

  def and_i_submit_the_international_application
    expect(page).to have_text('Review application')
    click_link_or_button 'Review application'
    click_link_or_button 'Continue'
    expect(page).to have_text('Check before you submit your application')
    click_link_or_button 'Confirm and submit application'
  end

  def when_i_click_to_review_my_application
    click_link_or_button 'Review application'
  end

  def when_i_click_to_submit_my_application
    click_link_or_button 'Confirm and submit application'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_text 'Application submitted'

    expect(@application_form.application_choices.first).to be_awaiting_provider_decision
  end

  def when_i_click_on_continue
    click_on 'Continue'
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_the_visa_may_not_cover_course_interruption
    expect(page).to have_current_path(
      candidate_interface_course_choices_visa_not_covered_interruption_review_path(@application_form.application_choices.first),
    )
    expect(page).to have_text('Your current visa may not cover this course')
    expect(page).to have_text(
      'Your visa is linked to your current studies or job. It may no longer be valid if you leave those to start this course.',
    )
    expect(page).to have_text(
      'You must have the right to study in the UK for the duration of the course. This course does not offer visa sponsorship.',
    )
    expect(page).to have_text(
      'You can continue your application and tell the training provider how you expect to stay in the UK for this course.',
    )
    expect(page).to have_text(
      'Alternatively, you can find a course that offers visa sponsorship (opens in new tab).',
    )
  end

  def then_i_see_the_visa_may_not_cover_course_interruption_for_a_course_sponsoring_visas
    expect(page).to have_current_path(
      candidate_interface_course_choices_visa_not_covered_interruption_review_path(@application_form.application_choices.first),
    )
    expect(page).to have_text('Your current visa may not cover this course')
    expect(page).to have_text(
      'Your visa is linked to your current studies or job. It may no longer be valid if you leave those to start this course.',
    )
    expect(page).to have_text(
      'You must have the right to study in the UK for the duration of the course.',
    )
    expect(page).to have_text(
      'You can continue your application and tell the training provider how you expect to stay in the UK for this course.',
    )
    expect(page).to have_text(
      'This course offers visa sponsorship, you may be able to extend your visa.'
    )
  end

  def then_see_the_visa_explanation_form_page
    expect(page).to have_current_path(
      candidate_interface_course_choices_visa_explanation_path(
        @application_form.application_choices.first,
      ),
    )
    expect(page).to have_text('How will you be able to stay in the UK for the duration of this course?')
    expect(page).to have_field('I expect to extend my current visa', type: :radio)
    expect(page).to have_field('I expect to have indefinite leave to remain (ILR) or settled status', type: :radio)
    expect(page).to have_field('I expect to switch to a different visa', type: :radio)
    expect(page).to have_field('Other', type: :radio)
    expect(page).to have_field('I’m not sure', type: :radio)
  end

  def when_i_select_i_expect_to_extend_my_current_visa
    choose 'I expect to extend my current visa'
  end
end

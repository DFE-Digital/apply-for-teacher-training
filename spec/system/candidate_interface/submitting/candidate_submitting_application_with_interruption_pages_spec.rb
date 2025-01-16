require 'rails_helper'

RSpec.describe 'Candidate submits the application with interruption pages' do
  include CandidateHelper

  scenario 'Candidate submits an application with all applications having an enic_reason of not_needed and personal statement less than 500 words', :js, time: mid_cycle do
    given_i_am_signed_in_with_one_login

    when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice_with_not_needed_qualification
    and_i_continue_with_my_application

    when_i_save_as_draft
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_still_unsubmitted
    and_i_continue_with_my_application

    when_i_click_to_review_my_application
    then_i_see_a_interruption_page_for_personal_statement
    when_i_continue_without_editing
    then_i_see_a_interruption_page_for_not_needed_enic
    then_the_viewed_enic_interruption_page_cookie_to_be_set
  end

  scenario 'Candidate submits an application with an application having an enic_reason of maybe and personal statement less than 500 words', :js, time: mid_cycle do
    given_i_am_signed_in_with_one_login

    when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice_with_waiting_or_maybe_qualification
    and_i_continue_with_my_application

    when_i_save_as_draft
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_still_unsubmitted
    and_i_continue_with_my_application

    when_i_click_to_review_my_application
    then_i_see_a_interruption_page_for_personal_statement
    when_i_continue_without_editing
    then_i_see_a_interruption_page_for_waiting_or_maybe_enic
    then_the_viewed_enic_interruption_page_cookie_to_be_set
  end

  scenario 'Candidate submits an application with an application having an enic_reason of maybe and personal statement of 500 words', :js, time: mid_cycle do
    given_i_am_signed_in_with_one_login

    when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice_with_waiting_or_maybe_qualification_and_personal_statement_500_words
    and_i_continue_with_my_application

    when_i_save_as_draft
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_still_unsubmitted
    and_i_continue_with_my_application

    when_i_click_to_review_my_application
    then_i_see_a_interruption_page_for_waiting_or_maybe_enic
    then_the_viewed_enic_interruption_page_cookie_to_be_set
  end

  scenario 'Candidate submits an teacher degree apprenticeship course having a personal statement less than 500 words and a degree', :js, time: mid_cycle do
    given_i_am_signed_in_with_one_login
    when_i_have_completed_application_to_primary_course_choice_with_short_personal_statement
    and_course_choice_is_undergraduate
    and_i_have_a_degree
    and_i_continue_with_my_application

    when_i_save_as_draft
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_still_unsubmitted
    and_i_continue_with_my_application

    when_i_click_to_review_my_application
    then_i_see_a_interruption_page_for_personal_statement
    when_i_continue_without_editing
    then_i_see_a_interruption_page_for_degree_warning
    when_i_click_to_continue_and_apply_for_the_course
    then_i_see_the_review_and_submit_page
  end

  scenario 'Candidate submits an teacher degree apprenticeship course having a degree with long personal statement and with ENIC', :js, time: mid_cycle do
    given_i_am_signed_in_with_one_login
    when_i_have_completed_application_to_primary_course_choice_with_long_personal_statement
    and_i_have_a_degree
    and_course_choice_is_undergraduate
    and_i_continue_with_my_application

    when_i_save_as_draft
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_still_unsubmitted
    and_i_continue_with_my_application

    when_i_click_to_review_my_application
    then_i_see_a_interruption_page_for_degree_warning
    when_i_click_to_continue_and_apply_for_the_course
    then_i_see_the_review_and_submit_page
  end

  def when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice_with_not_needed_qualification
    given_i_have_a_primary_course_choice(application_form_completed: true, personal_statement_words: 4)
    add_not_needed_qualification
  end

  def when_i_have_completed_application_to_primary_course_choice_with_short_personal_statement
    given_i_have_a_primary_course_choice(application_form_completed: true, personal_statement_words: 4)
  end

  def and_course_choice_is_undergraduate
    @application_choice.course.update!(
      build(:course, :teacher_degree_apprenticeship)
      .attributes
      .symbolize_keys
      .slice(:apprenticeship, :full_time, :description, :qualifications, :program_type, :course_length),
    )
  end

  def when_i_have_completed_application_to_primary_course_choice_with_long_personal_statement
    given_i_have_a_primary_course_choice(application_form_completed: true, personal_statement_words: 500)
  end

  def and_i_have_a_degree
    create(
      :degree_qualification,
      application_form: @application_choice.application_form,
      institution_country: 'GB',
    )
  end

  def when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice_with_waiting_or_maybe_qualification
    given_i_have_a_primary_course_choice(application_form_completed: true, personal_statement_words: 4)
    add_waiting_or_maybe_qualification
  end

  def when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice_with_waiting_or_maybe_qualification_and_personal_statement_500_words
    given_i_have_a_primary_course_choice(application_form_completed: true, personal_statement_words: 500)
    add_waiting_or_maybe_qualification
  end

  def given_i_have_a_primary_course_choice(application_form_completed:, personal_statement_words:)
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
    @course = create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider)
    @course_option = create(:course_option, site:, course: @course)
    @current_candidate.application_forms << create(:application_form, completed_section_trait, :with_degree, becoming_a_teacher: Faker::Lorem.words(number: personal_statement_words))
    @application_choice = create(:application_choice, :unsubmitted, course_option: @course_option, application_form: @current_candidate.current_application)
  end

  def add_not_needed_qualification
    @application_choice.application_form.application_qualifications << build(:application_qualification, enic_reason: 'not_needed')
  end

  def add_waiting_or_maybe_qualification
    @application_choice.application_form.application_qualifications << build(:application_qualification, enic_reason: 'maybe')
  end

  def when_i_save_as_draft
    click_link_or_button 'Save as draft'
  end

  def and_my_application_is_still_unsubmitted
    expect(@application_choice.reload).to be_unsubmitted
  end

  def and_i_am_redirected_to_the_application_dashboard
    expect(page).to have_content t('page_titles.application_dashboard')
    expect(page).to have_content 'Gorse SCITT'
  end

  def when_i_go_back
    click_link_or_button 'Back'
  end

  def then_i_see_a_interruption_page_for_personal_statement
    expect(page).to have_content 'Your personal statement is 4 words.'
  end

  def then_i_see_a_interruption_page_for_degree_warning
    expect(page).to have_content('Are you sure you want to apply for a teacher degree apprenticeship?')
    expect(page).to have_content('Teacher degree apprenticeships are 4 years, and postgraduate teacher training courses are usually one year.')
  end

  def then_i_see_a_interruption_page_for_not_needed_enic
    expect(page).to have_content 'You have not included a UK ENIC reference number'
    expect(page).to have_content 'Including a UK ENIC reference number in your application makes you around 30% more likely to receive an offer.'
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_review_enic_interruption_path(@application_choice.id),
    )
  end

  def then_i_see_a_interruption_page_for_waiting_or_maybe_enic
    expect(page).to have_content 'You have not included a UK ENIC reference number'
    expect(page).to have_content 'If you have a UK ENIC reference number, you should add it to your qualifications details.'
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_review_enic_interruption_path(@application_choice.id),
    )
  end

  def then_the_viewed_enic_interruption_page_cookie_to_be_set
    expect(page.driver.browser.manage.cookie_named('viewed_enic_interruption_page')[:value]).to eq('true')
  end

  def when_i_click_to_continue_and_apply_for_the_course
    click_link_or_button 'Continue and apply for this course'
  end

  def then_i_see_the_review_and_submit_page
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_review_and_submit_path(@application_choice.id),
    )
    expect(page).to have_content('Review your application')
  end
end

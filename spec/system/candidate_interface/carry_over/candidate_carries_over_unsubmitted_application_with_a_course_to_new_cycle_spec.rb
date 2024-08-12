require 'rails_helper'

RSpec.describe 'Carry over application and submit new application choices', time: CycleTimetableHelper.mid_cycle do
  include CandidateHelper

  it 'Candidate carries over unsubmitted application with a course to new cycle' do
    given_i_am_signed_in_as_a_candidate
    when_i_have_an_unsubmitted_application
    and_the_recruitment_cycle_ends
    and_the_cancel_unsubmitted_applications_worker_runs

    when_i_sign_in_again
    then_i_am_redirected_to_the_carry_over_interstitial

    when_i_click_on_continue
    then_i_see_a_copy_of_my_application

    when_i_view_referees
    then_i_can_see_the_referees_i_previously_added

    when_i_view_courses
    then_i_can_see_that_i_need_to_select_courses

    when_i_add_a_course
    and_i_visit_the_application_dashboard
    and_i_click_on_the_course_name
    then_i_see_the_course_choice_review_page

    when_i_complete_the_rest_of_my_details
    and_i_visit_the_application_dashboard
    and_i_click_on_the_course_name
    then_i_can_submit_my_application
    then_my_application_is_awaiting_provider_decision
  end

private

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsubmitted_application
    @application_form = create(
      :completed_application_form,
      :eligible_for_free_school_meals,
      :with_gcses,
      submitted_at: nil,
      candidate: @candidate,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
      references_count: 0,
    )
    @application_choice = create(
      :application_choice,
      status: :unsubmitted,
      application_form: @application_form,
    )
    @first_reference = create(
      :reference,
      feedback_status: :not_requested_yet,
      application_form: @application_form,
    )
    @second_reference = create(
      :reference,
      feedback_status: :feedback_requested,
      application_form: @application_form,
    )
  end

  def and_the_recruitment_cycle_ends
    advance_time_to(after_apply_reopens)
  end

  def and_the_cancel_unsubmitted_applications_worker_runs
    CancelUnsubmittedApplicationsWorker.new.perform
  end

  def when_i_sign_in_again
    logout
    login_as(@candidate)
    visit('/')
  end

  def and_i_visit_the_application_dashboard
    click_on 'Your applications'
  end

  def then_i_am_redirected_to_the_carry_over_interstitial
    expect(page).to have_current_path candidate_interface_start_carry_over_path
  end

  def when_i_click_on_continue
    click_link_or_button 'Continue'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_content 'Your application'
  end

  def when_i_view_referees
    click_link_or_button 'References to be requested if you accept an offer'
  end
  alias_method :click_on_references, :when_i_view_referees

  def then_i_can_see_the_referees_i_previously_added
    expect(page).to have_css('h3', text: @first_reference.name)
    expect(page).to have_css('h3', text: @second_reference.name)
  end

  def when_i_view_courses
    click_link_or_button 'Your applications'
  end

  def then_i_can_see_that_i_need_to_select_courses
    expect(page).to have_content('You can add up to 4 applications at a time.')
  end

  def when_i_add_a_course
    given_courses_exist
    click_link_or_button 'Add application'

    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')

    choose 'Primary (2XT2)'
    click_link_or_button t('continue')

    expect(page).to have_content('Primary (2XT2)')
    expect(page).to have_content 'You cannot submit this application until you complete your details.'
    expect(page).to have_content 'Your application will be saved as a draft while you finish adding your details'
  end

  def and_i_visit_the_course_choices_section
    click_link_or_button 'Your applications'
  end

  def and_i_click_on_the_course_name
    within 'div.app-application-item' do
      expect(page).to have_text application_choice.provider.name
      link = page.find_link
      link.click
    end
  end

  def then_i_see_the_course_choice_review_page
    expect(page).to have_current_path(
      candidate_interface_continuous_applications_course_review_path(
        application_choice_id: application_choice.id,
      ),
    )
    expect(page).to have_content 'Not submitted yet'
  end

  def when_i_complete_the_rest_of_my_details
    click_on 'Your details'
    click_on_references
    complete_section
    click_on 'Your details'
    click_on 'Equality and diversity questions'
    # Sex
    choose 'Prefer not to say'
    click_on 'Continue'
    # Disabilities
    check 'Prefer not to say'
    click_on 'Continue'
    # Ethnicity
    choose 'Prefer not to say'
    click_on 'Continue'
    # Free school meals
    choose 'Prefer not to say'
    click_on 'Continue'
    complete_section
  end

  def then_i_can_submit_my_application
    expect(page).to have_content 'Review and submit your application'
    click_on 'Review application'
    click_on 'Confirm and submit application'
    expect(page).to have_content 'Application submitted'
    expect(page).to have_content 'You can add 3 more applications'
  end

  def and_i_complete_the_section
    choose t('application_form.completed_radio')
    click_link_or_button t('continue')
  end
  alias_method :complete_section, :and_i_complete_the_section

  def and_i_receive_references
    receive_references
    mark_references_as_complete
  end

  def then_my_application_is_awaiting_provider_decision
    expect(page).to have_content 'Awaiting decision'
    expect(application_choice.status).to eq('awaiting_provider_decision')
  end

  def application_choice
    @candidate.current_application.application_choices.first
  end
end

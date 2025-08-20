require 'rails_helper'

RSpec.describe 'Candidate can carry over unsuccessful application to a new recruitment cycle after the apply deadline' do
  include CandidateHelper
  include ApplicationHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
    @candidate = create(:candidate)
  end

  scenario 'a candidate who was unsuccessful from years ago can carry over mid cycle' do
    given_i_applied_two_years_ago
    when_i_sign_in
    then_i_can_see_the_carry_over_content_for_mid_cycle
    and_i_can_view_my_unsuccessful_application

    when_i_click_back
    and_i_carry_over_my_application_mid_cycle
    then_i_can_edit_my_details
  end

  scenario 'a candidate who was unsuccessful years ago can carry over between cycles' do
    given_i_applied_two_years_ago
    and_the_apply_deadline_passes
    when_i_sign_in
    then_i_can_see_the_carry_over_content_for_between_cycles
    and_i_can_view_my_unsuccessful_application

    when_i_click_back
    and_i_carry_over_my_application_between_cycles
    then_i_can_edit_my_details
  end

  scenario 'an unsuccessful candidate from this cycle can carry over the application between cycles' do
    given_i_have_an_application_with_a_rejection
    and_the_apply_deadline_passes
    when_i_sign_in
    then_i_can_see_the_carry_over_content_for_between_cycles

    and_i_carry_over_my_application_between_cycles
    then_i_can_edit_my_details
  end

  scenario 'when an unsuccessful candidate from this cycle can re-apply in the next cycle by carrying over their original application' do
    given_i_have_an_application_with_a_rejection
    and_the_next_cycle_opens
    when_i_sign_in
    then_i_can_see_the_carry_over_content_for_mid_cycle
    and_i_can_view_my_unsuccessful_application

    when_i_click_back
    and_i_carry_over_my_application_mid_cycle
    then_i_can_add_course_choices
  end

  scenario 'Candidate can see the add another job button in the new cycle' do
    given_i_have_an_application_with_a_rejection
    and_the_apply_deadline_passes
    when_i_sign_in

    and_i_carry_over_my_application_between_cycles
    and_the_next_cycle_opens
    and_i_sign_in
    and_i_click_on_work_history
    then_i_see_the_add_another_job_button
  end

  def and_i_click_on_work_history
    expect(page).to have_content 'Your details'
    click_link_or_button 'Work history'
  end

  def then_i_see_the_add_another_job_button
    expect(page).to have_link('Add another job', href: '/candidate/application/restructured-work-history/new', class: 'govuk-button govuk-button--secondary')
  end

  def when_i_sign_in
    logout
    login_as(@candidate)
    visit root_path
  end
  alias_method :and_i_sign_in, :when_i_sign_in

  def and_i_have_an_application_with_a_rejection
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    @application_choice = create(:application_choice, :rejected, application_form: @application_form)

    job = create(:application_work_experience, experienceable: @application_form)
    @application_form.application_work_experiences << [job]
    @provider = @application_choice.provider
  end
  alias_method :given_i_have_an_application_with_a_rejection, :and_i_have_an_application_with_a_rejection

  def given_i_applied_two_years_ago
    @application_form = create(:completed_application_form, recruitment_cycle_year: 2.years.ago.year, candidate: @candidate)
    @application_choice = create(:application_choice, :rejected, application_form: @application_form)
    @provider = @application_choice.provider
    @provider.update(name: "St. Mary's")
  end

  def and_the_apply_deadline_passes
    advance_time_to(after_apply_deadline)
  end

  def and_i_visit_my_application_complete_page
    logout
    login_as(@candidate)
    visit candidate_interface_application_choices_path
  end

  def and_i_refresh_the_page
    @url = page.current_url
    visit @url
  end

  def and_i_click_go_to_my_application_form
    click_link_or_button 'Go to your application form'
  end

  def then_i_see_the_carry_over_inset_text
    expect(page).to have_content "You can apply for courses starting in the #{current_timetable.academic_year_range_name} academic year instead."
  end

  def then_i_can_see_the_carry_over_content_for_mid_cycle
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_content 'Continue your application'

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      expect(page).to have_button 'Continue'
    end
  end

  def then_i_can_see_the_carry_over_content_for_between_cycles
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_content 'The application deadline has passed'

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      expect(page).to have_button 'Update your details'
    end
  end

  def and_i_can_view_my_unsuccessful_application
    click_on @provider.name
    expect(page)
      .to have_current_path(
        candidate_interface_course_choices_course_review_path(
          application_choice_id: @application_choice.id,
        ),
      )
    expect(page).to have_title("Your application to #{@provider.name}")
    expect(page).to have_content('Unsuccessful')
  end

  def and_the_next_cycle_opens
    advance_time_to(after_apply_reopens)
  end

  def and_i_visit_my_details_page
    click_on 'Your details'
  end

  def when_i_click_back
    click_on 'Back to your applications'
  end

  def when_i_carry_over_my_application_mid_cycle
    click_on 'Continue'
  end
  alias_method :and_i_carry_over_my_application_mid_cycle, :when_i_carry_over_my_application_mid_cycle

  def and_i_carry_over_my_application_between_cycles
    click_on 'Update your details'
  end

  def then_i_can_edit_my_details
    click_on 'Your details'
    click_on 'Personal information'

    within '[data-qa="personal-details-name"]' do
      expect(page).to have_link 'Change'
    end
  end
end

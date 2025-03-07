require 'rails_helper'

RSpec.describe 'Candidate review application when visa deadline has passed' do
  before do
    FeatureFlag.activate(:early_application_deadlines_for_candidates_with_visa_sponsorship)
  end

  scenario 'Candidate with a draft application', time: mid_cycle do
    given_i_require_visa_sponsorship
    given_have_a_draft_application_for_a_course_with_a_visa_sponsorship_application_deadline_in_the_past
    and_i_am_signed_in

    when_i_view_my_application_choice
    then_i_see_the_warning_text
    and_i_can_delete_my_application_choice
  end

private

  def given_have_a_draft_application_for_a_course_with_a_visa_sponsorship_application_deadline_in_the_past
    @course = create(:course, :open, :secondary, visa_sponsorship_application_deadline_at: 1.second.ago)
    course_option = create(:course_option, course: @course)
    @application_choice = create(:application_choice, :unsubmitted, course_option:, application_form: @application_form)
  end

  def given_i_require_visa_sponsorship
    @application_form = create(:application_form, :completed, :with_degree, right_to_work_or_study: 'no')
  end

  def and_i_am_signed_in
    @current_candidate = @application_form.candidate
    i_am_signed_in_with_one_login
  end

  def when_i_view_my_application_choice
    click_on 'Your applications'
    click_on @course.provider.name
  end

  def then_i_see_the_warning_text
    within('.govuk-warning-text') do
      expect(page).to have_text 'This course is closed to candidates who need visa sponsorship now.'
    end

    expect(page).to have_text 'You cannot apply to this course. You should choose another course or subject at another training provider who is still accepting applications.'
    expect(page).to have_text 'Delete draft application'
  end

  def and_i_can_delete_my_application_choice
    click_on 'delete your draft application'
    click_on 'Yes I’m sure - delete this application'
    expect(page.current_url).to end_with(candidate_interface_application_choices_path)

    expect(page).to have_no_text @course.provider.name
  end
end

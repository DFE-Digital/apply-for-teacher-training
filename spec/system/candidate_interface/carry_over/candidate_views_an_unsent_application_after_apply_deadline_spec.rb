require 'rails_helper'

RSpec.describe 'Views an unsent application after the apply deadline', time: CycleTimetableHelper.mid_cycle do
  include CandidateHelper

  scenario 'candidate has a draft application' do
    given_i_have_a_draft_application
    and_the_apply_deadline_passes
    when_i_sign_in
    and_i_click_on_your_applications
    then_i_see_my_applications_page
    and_i_can_view_the_application
  end

private

  def given_i_have_a_draft_application
    @application_choice = create(:application_choice, :unsubmitted, :with_completed_application_form)
    @application_form = @application_choice.application_form
    @candidate = @application_form.candidate
  end

  def and_the_apply_deadline_passes
    advance_time_to(after_apply_deadline)
    EndOfCycle::CancelUnsubmittedApplicationsWorker.perform_now
  end

  def when_i_sign_in
    login_as @candidate
    visit root_path
  end

  def and_i_click_on_your_applications
    click_on 'Your applications'
  end

  def then_i_see_my_applications_page
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_text 'Your applications'
    expect(page).to have_text 'Application not sent'
  end

  def and_i_can_view_the_application
    click_on @application_choice.provider.name
    expect(page).to have_current_path(
    candidate_interface_course_choices_course_review_path(
      application_choice_id: @application_choice.id,
      ),
    )
    expect(page).to have_title("Your application to #{@application_choice.provider.name}")
    expect(page).to have_text('Application not sent')
  end
end

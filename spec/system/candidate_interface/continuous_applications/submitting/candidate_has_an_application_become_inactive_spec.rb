require 'rails_helper'

RSpec.feature 'Candidate with submitted applications' do
  include CandidateHelper

  scenario 'Application becomes inactive' do
    given_i_am_signed_in
    and_i_have_submitted_applications

    when_one_of_my_applications_becomes_inactive
    then_i_can_see_the_change_in_content
    and_i_can_add_another_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_submitted_applications
    current_candidate.application_forms << build(:application_form, :completed)
    current_candidate.current_application.application_choices << build_list(:application_choice, 4, :awaiting_provider_decision)
    @application_choice = current_candidate.current_application.application_choices.last
    @application_choice.update(reject_by_default_at: Time.zone.now)
  end

  def when_one_of_my_applications_becomes_inactive
    travel_temporarily_to(10.minutes.from_now) do
      ProcessStaleApplicationsWorker.perform_async
    end
  end

  def then_i_can_see_the_change_in_content
    and_i_visit_application_choices_list
    when_i_click_to_view_my_application
    expect(page).to have_content(
      'You can add an application for a different training provider while you wait for a decision on this application.',
    )
  end

  def and_i_can_add_another_application
    expect(page).to have_content('You can add 1 more application.')
  end
end

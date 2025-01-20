require 'rails_helper'

RSpec.describe 'Candidate with submitted applications' do
  include ActionView::Helpers::DateHelper
  include CandidateHelper

  scenario 'Application becomes inactive' do
    given_i_am_signed_in_with_one_login
    and_i_have_submitted_applications
    when_one_of_my_applications_becomes_inactive
    when_i_visit_my_applications
    then_i_can_add_another_application
    when_i_click_to_view_my_application
    then_i_can_see_the_change_in_content
    and_i_can_see_the_inactive_warning_content
    given_i_can_not_add_more_choices
    when_i_visit_my_applications
    when_i_click_to_view_my_application
    then_i_can_not_see_the_inactive_warning_text
  end

  def and_i_have_submitted_applications
    current_candidate.application_forms << build(:application_form, :completed)
    current_candidate.current_application.application_choices << build_list(:application_choice, 4, :awaiting_provider_decision, sent_to_provider_at: 1.day.ago)
    @application_choice = current_candidate.current_application.application_choices.last
    @application_choice.update(reject_by_default_at: Time.zone.now)
  end

  def when_one_of_my_applications_becomes_inactive
    travel_temporarily_to(10.minutes.from_now) do
      ProcessStaleApplicationsWorker.perform_async
    end
  end

  def then_i_can_see_the_change_in_content
    expect(page).to have_content('The provider will review your application and let you know when they have made a decision. In the meantime, you can:')
    expect(page).to have_content('submit another application while you wait for a decision on this one')
  end

  def given_i_can_not_add_more_choices
    create(:application_choice, :awaiting_provider_decision, application_form: current_candidate.current_application)
  end

  def and_i_can_see_the_inactive_warning_content
    expect(page).to have_content(
      "Application submitted #{time_ago_in_words(application_choice.sent_to_provider_at)} ago",
    )
    expect(page).to have_content(
      'You can add an application for a different training provider while you wait for a decision on this application.',
    )
  end

  def then_i_can_add_another_application
    expect(page).to have_content('You can add 1 more application.')
  end

  def then_i_can_not_see_the_inactive_warning_text
    expect(page).to have_no_content(
      'You can add an application for a different training provider while you wait for a decision on this application',
    )
  end
end

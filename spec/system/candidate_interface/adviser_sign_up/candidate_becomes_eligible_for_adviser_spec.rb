require 'rails_helper'

RSpec.describe 'Candidate becomes eligible for an adviser' do
  include CandidateHelper

  it 'displays the adviser sign up CTA when eligible' do
    given_i_am_signed_in_with_one_login
    and_enqueued_jobs_are_not_performed
    and_the_api_call_is_stubbed
    and_analytics_is_enabled

    when_i_have_an_eligible_application
    and_i_visit_the_details_page
    then_i_do_see_the_adviser_cta
    and_the_adviser_offering_is_tracked

    when_i_remove_my_degrees
    and_i_visit_the_details_page
    then_i_do_not_see_the_adviser_cta
  end

  def and_enqueued_jobs_are_not_performed
    ActiveJob::Base.queue_adapter = :test
  end

  def and_analytics_is_enabled
    allow(DfE::Analytics).to receive(:enabled?).and_return(true)
  end

  def and_i_visit_the_details_page
    visit candidate_interface_details_path
  end

  def and_the_api_call_is_stubbed
    api_double = instance_double(
      GetIntoTeachingApiClient::TeacherTrainingAdviserApi,
      matchback_candidate: nil,
    )
    allow(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to receive(:new) { api_double }
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def when_i_have_an_eligible_application
    create(:application_form_eligible_for_adviser, candidate: @current_candidate)
  end

  def then_i_do_see_the_adviser_cta
    expect(page).to have_link(t('candidate_interface.details.adviser_call_to_action.available.button_text'))
  end

  def and_the_adviser_offering_is_tracked
    expect(:candidate_offered_adviser).to have_been_enqueued_as_analytics_events
  end

  def when_i_remove_my_degrees
    @current_candidate.current_application.application_qualifications.degrees.destroy_all
  end

  def then_i_do_not_see_the_adviser_cta
    expect(page).to have_no_link(t('candidate_interface.details.adviser_call_to_action.available.button_text'))
  end
end

require 'rails_helper'

RSpec.feature 'Candidate becomes eligible for an adviser' do
  include CandidateHelper

  it 'displays the adviser sign up CTA when eligible' do
    given_i_am_signed_in
    and_enqueued_jobs_are_not_performed
    and_the_adviser_sign_up_feature_flag_is_disabled

    when_i_have_an_eligible_application
    and_the_candidate_does_not_matchback
    and_i_visit_the_application_form_page
    then_i_should_not_see_the_adviser_cta

    when_the_adviser_sign_up_feature_flag_is_enabled
    and_i_visit_the_application_form_page
    then_i_should_see_the_adviser_cta
    and_the_adviser_offering_should_be_tracked

    when_i_remove_my_degrees
    and_i_visit_the_application_form_page
    then_i_should_not_see_the_adviser_cta
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_enqueued_jobs_are_not_performed
    ActiveJob::Base.queue_adapter = :test
  end

  def and_the_adviser_sign_up_feature_flag_is_disabled
    FeatureFlag.deactivate(:adviser_sign_up)
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_continuous_applications_details_path
  end

  def and_the_candidate_does_not_matchback
    api_double = instance_double(GetIntoTeachingApiClient::TeacherTrainingAdviserApi)
    allow(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to receive(:new) { api_double }
    allow(api_double).to receive(:matchback_candidate).and_raise(
      GetIntoTeachingApiClient::ApiError.new(code: 404),
    )
  end

  def when_the_adviser_sign_up_feature_flag_is_enabled
    FeatureFlag.activate(:adviser_sign_up)
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def when_i_have_an_eligible_application
    create(:application_form_eligible_for_adviser, candidate: @candidate)
  end

  def then_i_should_see_the_adviser_cta
    expect(page).to have_link(t('application_form.adviser_sign_up.call_to_action.available.button_text'))
  end

  def and_the_adviser_offering_should_be_tracked
    expect(:candidate_offered_adviser).to have_been_enqueued_as_analytics_events
  end

  def when_i_remove_my_degrees
    @candidate.current_application.application_qualifications.degrees.destroy_all
  end

  def then_i_should_not_see_the_adviser_cta
    expect(page).to have_no_link(t('application_form.adviser_sign_up.call_to_action.available.button_text'))
  end
end

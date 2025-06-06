require 'rails_helper'

RSpec.describe 'Candidate signs up for an adviser', :js do
  include_context 'get into teaching api stubbed endpoints'

  include CandidateHelper

  it 'redirects back to review their application' do
    given_i_am_signed_in_with_one_login
    and_adviser_teaching_subjects_exist
    and_rails_cache_is_enabled
    and_analytics_is_enabled
    and_enqueued_jobs_are_not_performed
    and_i_have_an_eligible_application
    and_the_adviser_sign_up_feature_flag_is_enabled
    and_the_get_into_teaching_api_is_accepting_sign_ups
    and_adviser_sign_up_jobs_can_be_enqueued
    and_i_visit_your_details_page

    when_i_click_on_the_adviser_cta
    then_i_am_on_the_adviser_sign_up_page

    when_i_click_request_an_adviser
    then_i_see_validation_errors_for_preferred_teaching_subject
    and_the_validation_error_is_tracked

    when_i_select_a_preferred_teaching_subject
    and_i_click_request_an_adviser
    then_i_am_redirected_to_your_details_page
    and_i_see_the_success_message
    and_the_adviser_cta_be_replaced_with_the_waiting_to_be_assigned_message
    and_an_adviser_sign_up_job_is_enqueued
    and_the_sign_up_is_tracked
  end

  def and_adviser_teaching_subjects_exist
    @preferred_teaching_subject1 = create(:adviser_teaching_subject, title: 'English Literature')
    @preferred_teaching_subject2 = create(:adviser_teaching_subject, title: 'Mathematics')
  end

  def and_rails_cache_is_enabled
    in_memory_store = ActiveSupport::Cache.lookup_store(:memory_store)
    allow(Rails).to receive(:cache).and_return(in_memory_store)
    Rails.cache.clear
  end

  def and_analytics_is_enabled
    allow(DfE::Analytics).to receive(:enabled?).and_return(true)
  end

  def and_enqueued_jobs_are_not_performed
    ActiveJob::Base.queue_adapter = :test
  end

  def and_the_adviser_sign_up_feature_flag_is_enabled
    FeatureFlag.activate(:adviser_sign_up)
  end

  def and_the_get_into_teaching_api_is_accepting_sign_ups
    @api_double = instance_double(GetIntoTeachingApiClient::TeacherTrainingAdviserApi, :sign_up_teacher_training_adviser_candidate, matchback_candidate: nil)
    allow(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to receive(:new) { @api_double }
  end

  def and_adviser_sign_up_jobs_can_be_enqueued
    allow(AdviserSignUpWorker).to receive(:perform_async)
  end

  def and_i_have_an_eligible_application
    @application_form = create(:application_form_eligible_for_adviser, candidate: @current_candidate)
  end

  def and_i_visit_your_details_page
    visit candidate_interface_details_path
  end

  def when_i_click_on_the_adviser_cta
    click_link_or_button t('candidate_interface.details.adviser_call_to_action.available.button_text')
  end

  def then_i_am_on_the_adviser_sign_up_page
    expect(page).to have_current_path(new_candidate_interface_adviser_sign_ups_path)
  end

  def then_i_am_returned_to_the_adviser_sign_up_page
    expect(page).to have_current_path(new_candidate_interface_adviser_sign_ups_path(preferred_teaching_subject_id: @preferred_teaching_subject1.external_identifier))
  end

  def when_i_click_request_an_adviser
    click_link_or_button 'Request an adviser'
  end
  alias_method :and_i_click_request_an_adviser, :when_i_click_request_an_adviser

  def then_i_see_validation_errors_for_preferred_teaching_subject
    expect(page).to have_content(
      t('activemodel.errors.models.adviser/sign_up_form.attributes.preferred_teaching_subject_id.inclusion'),
    )
  end

  def and_the_validation_error_is_tracked
    last_error = ValidationError.last
    expect(last_error).to have_attributes({
      form_object: Adviser::SignUpForm.name,
      request_path: page.current_path,
    })
  end

  def when_i_select_a_preferred_teaching_subject
    find('label', text: @preferred_teaching_subject1.title).click
  end

  def then_i_am_redirected_to_your_details_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end

  def and_i_see_the_success_message
    expect(page).to have_content(t('candidate_interface.adviser_sign_ups.create.flash.success'))
  end

  def and_an_adviser_sign_up_job_is_enqueued
    expect(AdviserSignUpWorker).to have_received(:perform_async).once
    expect(Adviser::SignUpRequest.last).to have_attributes(application_form: @application_form)
  end

  def and_the_adviser_cta_be_replaced_with_the_waiting_to_be_assigned_message
    expect(page).to have_no_link(t('candidate_interface.details.adviser_call_to_action.available.button_text'))
    expect(page).to have_text(t('candidate_interface.details.adviser_call_to_action.waiting_to_be_assigned.text'))
  end

  def and_the_sign_up_is_tracked
    expect(:candidate_signed_up_for_adviser).to have_been_enqueued_as_analytics_events
  end

  def then_i_am_redirected_to_the_review_page
    expect(page).to have_link(t('candidate_interface.adviser_sign_ups.show.change'))
    expect(page).to have_button(t('candidate_interface.adviser_sign_ups.show.request'))
  end
end

require 'rails_helper'

RSpec.describe 'Candidate with a degree subject that matches an adviser teaching subject selects yes on adviser interruption', :js do
  include CandidateHelper

  it 'proceeds to the review step of the adviser sign up flow' do
    given_i_am_signed_in_with_one_login
    and_i_have_an_eligible_application # value of adviser_interruption_response is 'nil' by default
    and_adviser_teaching_subjects_exist
    and_rails_cache_is_enabled
    and_analytics_is_enabled
    and_enqueued_jobs_are_not_performed
    and_the_adviser_sign_up_feature_flag_is_enabled
    and_the_get_into_teaching_api_is_accepting_sign_ups
    and_adviser_sign_up_jobs_can_be_enqueued

    when_i_visit_my_details_page
    and_i_navigate_to_a_section_which_determines_eligibilty # can be personal details, contact details, English/Maths, degree
    and_i_mark_this_section_as_completed
    and_i_click_continue
    then_i_see_the_interruption_page

    when_i_select_yes
    and_i_click_continue
    then_i_see_the_review_page_with_the_subject_prefilled

    when_i_click_change
    and_i_select_a_different_subject
    and_i_click_continue
    then_i_see_the_new_subject_is_prefilled

    when_i_click_request_adviser
    then_i_see_my_details_page
    and_i_see_the_success_message
  end

  def and_rails_cache_is_enabled
    in_memory_store = ActiveSupport::Cache.lookup_store(:memory_store)
    allow(Rails).to receive(:cache).and_return(in_memory_store)
    Rails.cache.clear
  end

  def and_i_have_an_eligible_application
    @eligible_application_form = create(:application_form_eligible_for_adviser, candidate: @current_candidate)
    @degree_subject = @eligible_application_form.recent_degree_subject
  end

  def and_adviser_teaching_subjects_exist
    @teaching_subject_1 = create(:adviser_teaching_subject, title: @degree_subject, external_identifier: 'matched_subject')
    @teaching_subject_2 = create(:adviser_teaching_subject, title: 'Primary Medicine')
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

  def when_i_visit_my_details_page
    visit candidate_interface_details_path
  end

  def and_i_navigate_to_a_section_which_determines_eligibilty
    click_link_or_button 'English GCSE or equivalent'
  end

  def and_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def when_i_select_yes
    within('fieldset.govuk-fieldset') do
      choose 'candidate-interface-adviser-interruption-form-proceed-to-request-adviser-yes-field'
    end
  end

  def then_i_see_the_interruption_page
    expect(page).to have_current_path(candidate_interface_adviser_sign_ups_interruption_path(@eligible_application_form.id))
  end

  def then_i_see_the_review_page_with_the_subject_prefilled
    expect(page).to have_current_path(candidate_interface_adviser_sign_up_path(@eligible_application_form.id, preferred_teaching_subject_id: @teaching_subject_1.external_identifier))
    expect(page).to have_content(@teaching_subject_1.title)
  end

  def when_i_click_change
    click_link_or_button 'Change'
  end

  def and_i_select_a_different_subject
    choose 'Primary Medicine'
  end

  def then_i_see_the_new_subject_is_prefilled
    expect(page).to have_current_path(candidate_interface_adviser_sign_up_path(@eligible_application_form.id, preferred_teaching_subject_id: @teaching_subject_2.external_identifier))
    expect(page).to have_content(@teaching_subject_2.title)
  end

  def when_i_click_request_adviser
    click_link_or_button 'Request adviser'
  end

  def then_i_see_my_details_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end

  def and_i_see_the_success_message
    expect(page).to have_content(t('candidate_interface.adviser_sign_ups.create.flash.success'))
  end
end

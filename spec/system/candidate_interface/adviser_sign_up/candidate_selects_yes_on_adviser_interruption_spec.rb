require 'rails_helper'

RSpec.describe 'Candidate selects yes on adviser interruption' do
  include CandidateHelper

  it 'proceeds to adviser sign up flow' do
    given_i_am_signed_in_with_one_login
    and_adviser_teaching_subjects_exist
    and_rails_cache_is_enabled
    and_analytics_is_enabled
    and_enqueued_jobs_are_not_performed
    and_the_adviser_sign_up_feature_flag_is_enabled
    and_the_get_into_teaching_api_is_accepting_sign_ups
    and_adviser_sign_up_jobs_can_be_enqueued
    and_i_have_an_eligible_application # value of adviser_interruption_response is 'nil' by default

    when_i_visit_my_details_page
    and_i_navigate_to_a_section_which_determines_eligibilty # can be personal details, contact details, English/Maths, degree
    and_i_mark_this_section_as_completed
    and_i_click_continue
    then_i_see_the_interruption_page

    when_i_select_yes
    and_i_click_continue
    then_i_see_the_select_a_subject_page

    when_i_click_back
    then_i_see_my_details_page

    when_i_navigate_to_a_section_which_determines_eligibilty
    and_i_mark_this_section_as_completed
    and_i_click_continue
    then_i_see_the_interruption_page_again

    when_i_select_yes
    and_i_click_continue
    then_i_see_the_select_a_subject_page

    when_i_select_a_subject
    and_i_click_continue
    then_i_see_the_review_page

    when_i_click_request_adviser
    then_i_see_my_details_page

    when_i_navigate_to_a_section_which_determines_eligibilty
    and_i_mark_this_section_as_completed
    and_i_click_continue
    then_i_do_not_see_the_interruption_page
    and_the_adviser_call_to_action_is_no_longer_visible
  end

  def and_rails_cache_is_enabled
    in_memory_store = ActiveSupport::Cache.lookup_store(:memory_store)
    allow(Rails).to receive(:cache).and_return(in_memory_store)
    Rails.cache.clear
  end

  def and_i_have_an_eligible_application
    @eligible_application_form = create(:application_form_eligible_for_adviser, candidate: @current_candidate)
  end

  def and_adviser_teaching_subjects_exist
    @teaching_subject_nuclear_physics = create(:adviser_teaching_subject, title: 'Primary Nuclear Physics', external_identifier: 'PNP001')
    @teaching_subject_optometry = create(:adviser_teaching_subject, title: 'Primary Optometry', external_identifier: 'PO001')
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
    choose 'Yes, I have completed this section'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_see_the_interruption_page
    expect(page).to have_current_path(candidate_interface_adviser_sign_ups_interruption_path(@eligible_application_form.id))
  end
  alias_method :then_i_see_the_interruption_page_again, :then_i_see_the_interruption_page

  def when_i_select_yes
    choose 'Yes'
  end

  def then_i_see_the_select_a_subject_page
    expect(page).to have_current_path(new_candidate_interface_adviser_sign_up_path)
  end

  def when_i_click_back
    click_link_or_button 'Back to your details'
  end

  def then_i_see_my_details_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end
  alias_method :then_i_do_not_see_the_interruption_page, :then_i_see_my_details_page

  def when_i_navigate_to_a_section_which_determines_eligibilty
    click_link_or_button 'Personal information'
  end

  def when_i_select_a_subject
    choose 'Primary Optometry'
  end

  def then_i_see_the_review_page
    expect(page).to have_current_path(candidate_interface_adviser_sign_up_path(@eligible_application_form.id, preferred_teaching_subject_id: @teaching_subject_optometry.external_identifier))
  end

  def when_i_click_request_adviser
    click_link_or_button 'Request adviser'
  end

  def and_the_adviser_call_to_action_is_no_longer_visible
    expect(page).to have_no_content('Get an adviser')
  end
end

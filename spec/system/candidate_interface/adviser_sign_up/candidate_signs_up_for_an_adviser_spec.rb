require 'rails_helper'

RSpec.feature 'Candidate signs up for an adviser', js: true do
  include_context 'get into teaching api stubbed endpoints'

  include CandidateHelper

  it 'redirects back to review their application' do
    given_i_am_signed_in
    and_the_adviser_sign_up_feature_flag_is_enabled
    and_the_get_into_teaching_api_is_accepting_sign_ups
    and_i_have_an_eligible_application
    and_i_visit_the_application_form_page

    when_i_click_on_the_adviser_cta
    then_i_should_be_on_the_adviser_sign_up_page

    when_i_click_the_sign_up_button
    then_i_should_see_validation_errors_for_preferred_teaching_subject
    and_the_validation_error_should_be_tracked

    when_i_fill_in_preferred_teaching_subject('unknown subject')
    when_i_click_the_sign_up_button
    then_i_should_see_validation_errors_for_preferred_teaching_subject

    when_i_fill_in_preferred_teaching_subject(preferred_teaching_subject.value)
    when_i_click_the_sign_up_button
    then_i_should_be_redirected_to_the_application_form_page
    and_i_should_see_the_success_message
    and_an_adviser_sign_up_job_should_be_enqueued
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_the_adviser_sign_up_feature_flag_is_enabled
    FeatureFlag.activate(:adviser_sign_up)
  end

  def and_the_get_into_teaching_api_is_accepting_sign_ups
    allow_any_instance_of(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to \
      receive(:sign_up_teacher_training_adviser_candidate)
  end

  def and_i_have_an_eligible_application
    create(:application_form_eligible_for_adviser, candidate: @candidate)
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_the_adviser_cta
    click_link t('application_form.adviser_sign_up.call_to_action')
  end

  def then_i_should_be_on_the_adviser_sign_up_page
    expect(page).to have_current_path(new_candidate_interface_adviser_sign_up_path)
  end

  def when_i_click_the_sign_up_button
    click_button t('application_form.adviser_sign_up.submit_text')
  end

  def then_i_should_see_validation_errors_for_preferred_teaching_subject
    expect(page).to have_content(
      t('activemodel.errors.models.adviser/sign_up.attributes.preferred_teaching_subject.inclusion'),
    )
  end

  def and_the_validation_error_should_be_tracked
    last_error = ValidationError.last
    expect(last_error).to have_attributes({
      form_object: Adviser::SignUp.name,
      request_path: page.current_path,
    })
  end

  def when_i_fill_in_preferred_teaching_subject(subject)
    fill_in 'Which subject are you interested in teaching?', with: subject
    # Triggering the autocomplete
    find('input[name="adviser_sign_up[preferred_teaching_subject_raw]"]').native.send_keys(:return)
  end

  def then_i_should_be_redirected_to_the_application_form_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def and_i_should_see_the_success_message
    expect(page).to have_content(t('application_form.adviser_sign_up.flash.success'))
  end

  def and_an_adviser_sign_up_job_should_be_enqueued; end
end

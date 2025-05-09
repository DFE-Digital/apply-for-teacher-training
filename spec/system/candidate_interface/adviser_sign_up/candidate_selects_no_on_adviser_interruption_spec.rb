require 'rails_helper'

RSpec.describe 'Candidate selects no on adviser interruption' do
  include CandidateHelper

  before do
    and_analytics_is_enabled
    and_the_adviser_sign_up_feature_flag_is_enabled
    and_the_get_into_teaching_api_is_accepting_sign_ups
  end

  it 'does not reappear when the candidate has selected no once' do
    given_i_am_signed_in_with_one_login
    and_i_have_an_eligible_application # value of adviser_interruption_response is 'nil' by default

    when_i_visit_my_details_page
    and_i_navigate_to_any_section # can be personal details, contact details, English/Maths, degree
    and_i_mark_this_section_as_completed
    and_i_click_continue
    then_i_see_the_interruption_page

    when_i_click_continue
    then_i_see_a_validation_error

    when_i_select_no
    and_i_click_continue
    then_i_see_my_details_page

    when_i_navigate_to_any_section
    and_i_mark_this_section_as_completed
    and_i_click_continue
    then_i_do_not_see_the_interruption_page
    and_the_adviser_call_to_action_is_still_visible
  end

  def and_analytics_is_enabled
    allow(DfE::Analytics).to receive(:enabled?).and_return(true)
  end

  def and_the_adviser_sign_up_feature_flag_is_enabled
    FeatureFlag.activate(:adviser_sign_up)
  end

  def and_the_api_call_is_stubbed
    api_double = instance_double(
      GetIntoTeachingApiClient::TeacherTrainingAdviserApi,
      matchback_candidate: nil,
    )
    allow(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to receive(:new) { api_double }
  end

  def and_the_get_into_teaching_api_is_accepting_sign_ups
    @api_double = instance_double(GetIntoTeachingApiClient::TeacherTrainingAdviserApi, :sign_up_teacher_training_adviser_candidate, matchback_candidate: nil)
    allow(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to receive(:new) { @api_double }
  end

  def and_analytics_is_enabled
    allow(DfE::Analytics).to receive(:enabled?).and_return(true)
  end

  def and_i_have_an_eligible_application
    @eligible_application_form = create(:application_form_eligible_for_adviser, candidate: @current_candidate)
  end

  def when_i_visit_my_details_page
    visit candidate_interface_details_path
  end

  def and_i_navigate_to_any_section
    click_link_or_button 'Degree'
  end

  def and_i_mark_this_section_as_completed
    choose 'Yes, I have completed this section'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_see_the_interruption_page
    expect(page).to have_current_path(candidate_interface_adviser_sign_ups_interruption_path)
  end

  def then_i_see_a_validation_error
    expect(page).to have_content('Select whether you would like to request a teacher training adviser')
  end

  def when_i_select_no
    choose 'No'
  end

  def then_i_see_my_details_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end
  alias_method :then_i_do_not_see_the_interruption_page, :then_i_see_my_details_page

  def when_i_navigate_to_any_section
    click_link_or_button 'Contact information'
  end

  def and_the_adviser_call_to_action_is_still_visible
    expect(page).to have_content('Get an adviser')
  end
end

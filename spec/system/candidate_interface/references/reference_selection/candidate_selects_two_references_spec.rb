require 'rails_helper'

RSpec.feature 'Candidate selects two references of many feedback_provided references' do
  include CandidateHelper

  scenario 'the candidate has received 4 references and must select 2 before completing the section' do
    given_i_am_signed_in
    and_the_reference_selection_feature_flag_is_active

    when_i_visit_the_select_references_page
    then_i_am_told_i_need_to_receive_references

    when_i_request_my_references
    and_i_visit_the_select_references_page
    then_i_am_told_i_need_to_receive_references

    when_i_receive_only_one_of_my_references
    and_i_visit_the_select_references_page
    then_i_am_told_i_need_to_receive_references

    when_i_have_received_all_my_references
    and_i_visit_the_select_references_page
    then_i_can_select_any_of_my_feedback_provided_references

    when_i_click_save_and_continue
    then_i_am_told_i_need_to_select_two_references

    when_i_select_3_references
    and_i_click_save_and_continue
    then_i_am_told_i_need_to_select_two_references

    when_i_select_2_references
    and_i_click_save_and_continue
    then_those_references_are_selected

    when_i_change_my_selected_references
    and_i_click_save_and_continue
    then_i_see_my_new_selection

    when_i_mark_the_section_as_incomplete
    and_i_click_save_and_continue
    then_i_see_the_section_is_incomplete

    when_i_revisit_the_select_references_page
    and_i_mark_the_section_as_completed
    and_i_click_save_and_continue
    then_i_see_the_references_section_is_complete
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
    @application = @candidate.current_application
  end

  def and_the_reference_selection_feature_flag_is_active
    FeatureFlag.activate('reference_selection')
  end

  def when_i_request_my_references
    create_list(:reference, 4, feedback_status: :feedback_requested, application_form: @application)
  end

  def when_i_receive_only_one_of_my_references
    reference = @application.application_references.last
    SubmitReference.new(reference: reference).save!
  end

  def when_i_have_received_all_my_references
    references = @application.application_references.where(feedback_status: 'feedback_requested')
    references.each { |reference| reference.update!(feedback_status: 'feedback_provided') }
  end

  def when_i_click_save_and_continue
    click_button 'Save and continue'
  end
  alias_method :and_i_click_save_and_continue, :when_i_click_save_and_continue

  def when_i_visit_the_select_references_page
    visit candidate_interface_select_references_path
  end
  alias_method :and_i_visit_the_select_references_page, :when_i_visit_the_select_references_page

  def then_i_am_told_i_need_to_receive_references
    expect(page).to have_content 'Once 2 or more references have been given, you can then select which you want to include'
  end

  def and_i_see_the_select_references_page
    expect(page).to have_current_path candidate_interface_select_references_path
  end

  def then_i_can_select_any_of_my_feedback_provided_references
    expect(page).to have_current_path candidate_interface_select_references_path
    provided_references = @application.application_references.feedback_provided
    @first_reference = provided_references.first
    @second_reference = provided_references.second
    @third_reference = provided_references.third
    @fourth_reference = provided_references.fourth

    expect(page).to have_content(@first_reference.name)
    expect(page).to have_content(@first_reference.referee_type.humanize)
    expect(page).to have_content(@second_reference.name)
    expect(page).to have_content(@second_reference.referee_type.humanize)
    expect(page).to have_content(@third_reference.name)
    expect(page).to have_content(@third_reference.referee_type.humanize)
    expect(page).to have_content(@fourth_reference.name)
    expect(page).to have_content(@fourth_reference.referee_type.humanize)
  end

  def then_i_am_told_i_need_to_select_two_references
    expect_validation_error 'Select 2 references'
  end

  def when_i_select_3_references
    check @first_reference.name
    check @second_reference.name
    check @third_reference.name
  end

  def when_i_select_2_references
    check @first_reference.name
    check @second_reference.name
  end

  def then_those_references_are_selected
    expect(page).to have_content @first_reference.name
    expect(page).to have_content @second_reference.name
    expect(page).not_to have_content @third_reference.name
  end

  def when_i_change_my_selected_references
    click_link 'Change'
    uncheck @first_reference.name
    uncheck @second_reference.name
    check @third_reference.name
    check @fourth_reference.name
  end

  def then_i_see_my_new_selection
    expect(page).to have_content @third_reference.name
    expect(page).to have_content @fourth_reference.name
    expect(page).not_to have_content @first_reference.name
    expect(page).not_to have_content @second_reference.name
  end

  def when_i_mark_the_section_as_incomplete
    choose t('application_form.incomplete_radio')
  end

  def when_i_revisit_the_select_references_page
    click_link 'Selected references'
  end

  def and_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def then_i_see_the_section_is_incomplete
    expect(page).to have_css('#selected-references-badge-id', text: 'Incomplete')
  end

  def then_i_see_the_references_section_is_complete
    expect(page).to have_css('#selected-references-badge-id', text: 'Completed')
  end
end

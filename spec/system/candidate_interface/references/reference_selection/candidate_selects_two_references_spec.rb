require 'rails_helper'

RSpec.feature 'Candidate selects two references of many feedback_provided references' do
  include CandidateHelper

  scenario 'the candidate has received 4 references and must select 2 before completing the section' do
    given_i_am_signed_in
    and_the_reference_selection_feature_flag_is_active
    and_i_have_requested_four_references
    when_i_visit_the_references_section
    then_i_cannot_complete_the_section_because_i_dont_have_any_references

    when_i_have_received_four_references
    and_i_visit_the_references_section
    and_i_choose_to_complete_the_section
    and_click_continue
    then_i_see_the_select_references_page
    and_i_see_all_my_feedback_provided_references

    when_i_click_continue
    then_i_am_told_i_need_to_select_two_references
    when_i_select_3_references
    and_click_continue
    then_i_am_told_i_need_to_select_two_references

    when_i_select_2_references
    and_click_continue
    then_those_references_are_selected
    and_the_references_section_is_complete
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
    @application = @candidate.current_application
  end

  def and_the_reference_selection_feature_flag_is_active
    FeatureFlag.activate('reference_selection')
  end

  def then_i_cannot_complete_the_section_because_i_dont_have_any_references
    expect(page).to have_content 'Have you completed this section?'
    when_i_choose_to_complete_the_section
    and_click_continue
    expect(page).to have_content I18n.t('application_form.references.review.need_two')
    expect(@application.reload.references_completed).to eq nil
  end

  def and_i_have_requested_four_references
    create_list(:reference, 4, feedback_status: :feedback_requested, application_form: @application)
  end

  def when_i_have_received_four_references
    @application.application_references.update_all(feedback_status: :feedback_provided)
  end

  def when_i_visit_the_references_section
    visit candidate_interface_references_review_path
  end
  alias_method :and_i_visit_the_references_section, :when_i_visit_the_references_section

  def when_i_choose_to_complete_the_section
    choose 'Yes, I have completed this section'
  end
  alias_method :and_i_choose_to_complete_the_section, :when_i_choose_to_complete_the_section

  def and_click_continue
    click_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_click_continue

  def then_i_see_the_select_references_page
    expect(page).to have_current_path candidate_interface_select_references_path
  end

  def and_i_see_all_my_feedback_provided_references
    provided_references = @application.application_references.feedback_provided
    @first_reference = provided_references.first
    @second_reference = provided_references.second
    @third_reference = provided_references.third
    @fourth_reference = provided_references.fourth

    expect(page).to have_content(@first_reference.single_line_identifier)
    expect(page).to have_content(@second_reference.single_line_identifier)
    expect(page).to have_content(@third_reference.single_line_identifier)
    expect(page).to have_content(@fourth_reference.single_line_identifier)
  end

  def then_i_am_told_i_need_to_select_two_references
    expect_validation_error 'Select 2 references'
  end

  def when_i_select_3_references
    check @first_reference.single_line_identifier
    check @second_reference.single_line_identifier
    check @third_reference.single_line_identifier
  end

  def when_i_select_2_references
    check @first_reference.single_line_identifier
    check @second_reference.single_line_identifier
  end

  def then_those_references_are_selected
    within find('#references_selected') do
      expect(page).to have_content @first_reference.name
      expect(page).to have_content @second_reference.name
      expect(page).not_to have_content @third_reference.name
    end

    within find('#references_given') do
      expect(page).not_to have_content @first_reference.name
      expect(page).not_to have_content @second_reference.name
      expect(page).to have_content @third_reference.name
    end
  end

  def and_the_references_section_is_complete
    click_link 'Back to application'
    expect(page).to have_css('#manage-your-references-badge-id', text: 'Completed')
  end
end

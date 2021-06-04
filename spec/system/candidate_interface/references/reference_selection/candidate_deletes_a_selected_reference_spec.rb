require 'rails_helper'

RSpec.feature 'References' do
  include CandidateHelper

  scenario 'the candidate deletes their selected references' do
    given_i_am_signed_in
    and_the_reference_selection_feature_flag_is_active

    given_i_receive_my_references_and_have_selected_two_of_them
    and_i_have_completed_the_section

    when_i_delete_one_of_the_selected_references
    then_i_am_redirected_to_the_references_review_page
    and_the_section_is_not_marked_as_completed

    when_i_select_my_other_reference
    and_complete_the_section
    then_the_section_is_marked_as_completed

    when_i_delete_one_of_the_selected_references
    then_i_am_redirected_to_the_references_review_page
    and_the_section_is_not_marked_as_completed

    when_i_visit_the_select_references_page
    then_i_am_presented_with_the_guidance
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
    @application = @candidate.current_application
  end

  def and_the_reference_selection_feature_flag_is_active
    FeatureFlag.activate('reference_selection')
  end

  def given_i_receive_my_references_and_have_selected_two_of_them
    create_list(:reference, 3, feedback_status: :feedback_provided, application_form: @application)
    @application.application_references[0..1].each { |reference| reference.update!(selected: true) }
  end

  def and_i_have_completed_the_section
    @application.update!(references_completed: true)
  end

  def when_i_delete_one_of_the_selected_references
    visit candidate_interface_references_review_path
    click_on "Delete reference #{@application.application_references.feedback_provided.first.name}"
    click_on I18n.t('application_form.references.delete_reference.confirm')
  end

  def then_i_am_redirected_to_the_references_review_page
    expect(page).to have_current_path candidate_interface_references_review_path
  end

  def and_the_section_is_not_marked_as_completed
    visit candidate_interface_application_form_path
    expect(page).to have_css('#select-your-references-badge-id', text: 'Incomplete')
  end

  def when_i_select_my_other_reference
    visit candidate_interface_select_references_path
    check @application.application_references.feedback_provided.first.name
    check @application.application_references.feedback_provided.second.name
    click_button 'Save and continue'
  end

  def and_complete_the_section
    choose t('application_form.completed_radio')
    click_button 'Save and continue'
  end

  def then_the_section_is_marked_as_completed
    expect(page).to have_css('#select-your-references-badge-id', text: 'Completed')
  end

  def when_i_visit_the_select_references_page
    visit candidate_interface_select_references_path
  end

  def then_i_am_presented_with_the_guidance
    expect(page).to have_current_path candidate_interface_select_references_path
    expect(page).to have_content 'Once you’ve received 2 or more references, you can select which ones to include in your application.'
  end
end

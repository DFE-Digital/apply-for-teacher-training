require 'rails_helper'

RSpec.feature 'Candidate provides feeback throughout the application process' do
  include CandidateHelper

  scenario 'Candidate without JS gives feedback while completing their applications' do
    given_i_am_signed_in
    and_the_feedback_prompts_flag_is_active

    when_i_visit_the_site
    and_i_click_on_the_references_section
    and_i_click_there_is_an_issue_with_the_section
    then_i_see_the_references_section_feedback_page

    when_i_fill_in_my_feedback
    then_i_see_the_thank_you_page
    and_my_first_set_of_feedback_has_been_collected

    when_i_click_go_back_to_previous_page
    then_i_see_the_references_start_page

    when_i_click_continue
    and_i_click_there_is_not_an_issue_with_the_section
    then_i_see_the_thank_you_page
    and_my_second_set_of_feedback_has_been_collected
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
    @application = @candidate.current_application
  end

  def and_the_feedback_prompts_flag_is_active
    FeatureFlag.activate(:feedback_prompts)
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_the_references_section
    click_link 'Add your references'
  end

  def and_i_click_there_is_an_issue_with_the_section
    click_button 'Yes'
  end

  def then_i_see_the_references_section_feedback_page
    expect(page).to have_current_path candidate_interface_edit_application_feedback_path(@application.application_feedback.last.id)
  end

  def when_i_fill_in_my_feedback
    check 'I do not understand this section'
    check 'My answers do not fit the format'
    fill_in :other_feedback, with: 'Me no understand.'
    choose 'Yes'

    click_button 'Submit feedback'
  end

  def then_i_see_the_thank_you_page
    expect(page).to have_current_path candidate_interface_application_feedback_thanks_path
  end

  def when_i_click_go_back_to_previous_page
    click_link 'Go back to page you were previously on'
  end

  def then_i_see_the_references_start_page
    expect(page).to have_current_path candidate_interface_references_start_path
  end

  def and_my_first_set_of_feedback_has_been_collected
    expect(@application.application_feedback.count).to eq 1
    expect(@application.application_feedback.last.section).to eq 'application_references'
    expect(@application.application_feedback.last.path).to eq 'candidate_interface_references_start_path'
    expect(@application.application_feedback.last.page_title).to eq t('page_titles.references_start')
    expect(@application.application_feedback.last.issues).to eq true
    expect(@application.application_feedback.last.does_not_understand_section).to eq true
    expect(@application.application_feedback.last.need_more_information).to eq false
    expect(@application.application_feedback.last.answer_does_not_fit_format).to eq true
    expect(@application.application_feedback.last.other_feedback).to eq 'Me no understand.'
    expect(@application.application_feedback.last.consent_to_be_contacted).to eq true
  end

  def when_i_click_continue
    click_link 'Continue'
  end

  def and_i_click_there_is_not_an_issue_with_the_section
    click_button 'No'
  end

  def and_my_second_set_of_feedback_has_been_collected
    expect(@application.application_feedback.count).to eq 2
    expect(@application.application_feedback.last.section).to eq 'application_references'
    expect(@application.application_feedback.last.path).to eq 'candidate_interface_references_type_path'
    expect(@application.application_feedback.last.page_title).to eq t('page_titles.references_type')
    expect(@application.application_feedback.last.issues).to eq false
    expect(@application.application_feedback.last.does_not_understand_section).to eq false
    expect(@application.application_feedback.last.need_more_information).to eq false
    expect(@application.application_feedback.last.answer_does_not_fit_format).to eq false
    expect(@application.application_feedback.last.other_feedback).to eq nil
    expect(@application.application_feedback.last.consent_to_be_contacted).to eq false
  end
end

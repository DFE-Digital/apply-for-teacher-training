require 'rails_helper'

RSpec.describe 'Entering their suitability to work with children' do
  include CandidateHelper

  scenario 'Candidate declares any safeguarding issues' do
    given_i_am_signed_in_with_one_login
    when_i_visit_the_site
    then_i_see_declaring_any_safeguarding_issues

    when_i_click_on_declaring_any_safeguarding_issues
    then_i_see_declaring_any_safeguarding_issues_form

    when_i_choose_yes
    and_enter_relevant_information
    and_i_click_on_continue
    then_i_see_my_relevant_information

    when_i_click_on_continue
    then_i_see_a_section_complete_error

    when_i_click_to_change_sharing_safeguarding_issues
    then_i_see_declaring_any_safeguarding_issues_form

    when_i_choose_no
    and_i_click_on_continue
    then_i_see_my_updated_answer

    when_i_mark_the_section_as_completed
    and_i_click_on_continue
    then_i_see_the_section_is_completed
  end

  def when_i_visit_the_site
    visit candidate_interface_details_path
  end

  def then_i_see_declaring_any_safeguarding_issues
    expect(page).to have_content(t('page_titles.suitability_to_work_with_children'))
  end

  def when_i_click_on_declaring_any_safeguarding_issues
    click_link_or_button t('page_titles.suitability_to_work_with_children')
  end

  def then_i_see_declaring_any_safeguarding_issues_form
    expect(page).to have_content('Do you want to declare any safeguarding issues, such as a criminal record or professional misconduct?')
  end

  def when_i_choose_yes
    choose 'Yes'
  end

  def and_enter_relevant_information
    fill_in 'Give any relevant information', with: 'I have a criminal conviction.'
  end

  def and_i_click_on_continue
    click_link_or_button t('continue')
  end

  def then_i_see_my_relevant_information
    expect(page).to have_content('Check your safeguarding declaration')
    expect(page).to have_content('I have a criminal conviction.')
  end

  def when_i_click_to_change_sharing_safeguarding_issues
    click_change_link 'if you want to share any safeguarding issues'
  end

  def when_i_choose_no
    choose 'No'
  end

  def then_i_see_my_updated_answer
    expect(page).to have_content 'Check your safeguarding declaration'
    expect(page).to have_content('No')
  end

  def when_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def when_i_click_on_continue
    click_link_or_button t('continue')
  end

  def then_i_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def then_i_see_the_section_is_completed
    expect(page).to have_css('#declare-any-safeguarding-issues-badge-id', text: 'Completed')
  end
end

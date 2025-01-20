require 'rails_helper'

RSpec.describe 'Candidate provides feedback during the application process' do
  include CandidateHelper

  it 'Candidate gives feedback while completing their applications' do
    given_i_am_signed_in

    when_i_visit_the_site
    and_i_click_on_the_references_section
    and_i_click_there_is_an_issue_with_the_section
    then_i_see_the_application_feedback_page

    when_i_fill_in_my_feedback
    then_i_see_the_thank_you_page
    and_my_first_set_of_feedback_has_been_collected
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application = @current_candidate.current_application
  end

  def when_i_visit_the_site
    visit candidate_interface_details_path
  end

  def and_i_click_on_the_references_section
    click_link_or_button 'References to be requested if you accept an offer'
  end

  def and_i_click_there_is_an_issue_with_the_section
    click_link_or_button t('application_feedback.feedback_link')
  end

  def then_i_see_the_application_feedback_page
    expect(page).to have_title 'How can we improve the references section?'
  end

  def when_i_fill_in_my_feedback
    fill_in(
      t('application_section_feedback.details_label', section: 'the references'),
      with: 'Me no understand.',
    )
    choose t('application_feedback.consent_to_be_contacted.yes', email_address: @current_candidate.email_address)

    click_link_or_button t('application_feedback.submit')
  end

  def then_i_see_the_thank_you_page
    expect(page).to have_current_path candidate_interface_application_feedback_thank_you_path
  end

  def and_my_first_set_of_feedback_has_been_collected
    expect(@application.application_feedback.count).to eq 1
    expect(@application.application_feedback.last.path).to eq '/candidate/application/references/review'
    expect(@application.application_feedback.last.page_title).to eq t('page_titles.references')
    expect(@application.application_feedback.last.feedback).to eq 'Me no understand.'
    expect(@application.application_feedback.last.consent_to_be_contacted).to be true
  end
end

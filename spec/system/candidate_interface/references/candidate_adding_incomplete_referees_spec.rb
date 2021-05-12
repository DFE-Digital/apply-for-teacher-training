require 'rails_helper'

RSpec.feature 'Candidate adding incomplete referees' do
  include CandidateHelper

  scenario 'Candidate adds incomplete referees' do
    given_i_am_signed_in
    and_i_have_provided_my_personal_details

    when_i_provide_a_referee_type_only
    then_i_see_that_referee_is_not_created

    when_i_provide_incomplete_referee_details
    then_i_see_that_the_incomplete_referee_is_created
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_provided_my_personal_details
    @candidate.current_application.update!(first_name: 'Michael', last_name: 'Antonio')
  end

  def when_i_provide_a_referee_type_only
    visit candidate_interface_references_start_path
    click_link t('continue')
    choose 'Academic'
    click_button t('continue')
  end

  def then_i_see_that_referee_is_not_created
    visit candidate_interface_references_review_path
    expect(page.text).to have_no_content('Academic')
  end

  def when_i_provide_incomplete_referee_details
    visit candidate_interface_references_start_path
    click_link t('continue')
    choose 'Academic'
    click_button t('continue')
    fill_in 'What is the referee’s name?', with: 'Mike Dean'
    click_button t('save_and_continue')
  end

  def then_i_see_that_the_incomplete_referee_is_created
    visit candidate_interface_references_review_path

    within_summary_row('Name') { expect(page.text).to have_content('Mike Dean') }
    within_summary_row('Email address') { expect(page.text).to have_content('Not entered') }
    within_summary_row('Reference type') { expect(page.text).to have_content('Academic') }
    within_summary_row('Relationship to referee') { expect(page.text).to have_content('Not entered') }
  end
end

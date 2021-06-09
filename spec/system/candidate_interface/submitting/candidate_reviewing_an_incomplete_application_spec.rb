require 'rails_helper'

RSpec.feature 'Candidate reviewing an incomplete application' do
  include CandidateHelper

  scenario 'sees everything incomplete from the current state' do
    given_i_am_signed_in

    when_i_visit_the_review_application_page
    then_i_should_be_able_to_click_through_and_complete_each_required_section

    when_i_confirm_my_application
    then_i_should_see_an_error_that_i_have_not_completed_everything
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_review_application_page
    visit candidate_interface_application_form_path
    click_link 'Check and submit your application'
  end

  def then_i_should_be_able_to_click_through_and_complete_each_required_section
    (application_form_sections - %i[science_gcse efl]).each do |section|
      within "#incomplete-#{section}-error" do
        expect(page).to have_selector("a[data-qa='incomplete-#{section}']")
      end
    end
  end

  def when_i_confirm_my_application
    click_link t('continue')
  end

  def then_i_should_see_an_error_that_i_have_not_completed_everything
    expect(page).to have_content t('page_titles.review_application')
    expect(page).to have_content 'There is a problem'
  end
end

require 'rails_helper'

RSpec.describe 'Personal statement', :js do
  include CandidateHelper

  before do
    create_and_sign_in_candidate
    @application_form = create(:application_form, candidate: current_candidate)
  end

  scenario 'when application is unsubmitted and showing full personal statement' do
    given_i_have_an_unsubmitted_application_with_short_personal_statement
    when_i_visit_my_applications
    when_i_click_to_view_my_application
    then_i_should_see_the_full_personal_statement
  end

  scenario 'when application is unsubmitted and personal statement is long' do
    given_i_have_an_unsubmitted_application_with_long_personal_statement
    when_i_visit_my_applications
    when_i_click_to_view_my_application
    then_i_should_see_only_the_short_personal_statement
    when_i_click_show_more
    then_i_should_see_the_whole_personal_statement
    when_i_click_show_less
    then_i_should_see_only_the_short_personal_statement
  end

  scenario 'when application is submitted and showing full personal statement' do
    given_i_have_an_submitted_application_with_short_personal_statement
    when_i_visit_my_applications
    when_i_click_to_view_my_application
    then_i_should_see_the_full_personal_statement
  end

  scenario 'when application is submitted and personal statement is long' do
    given_i_have_an_submitted_application_with_long_personal_statement
    when_i_visit_my_applications
    when_i_click_to_view_my_application
    then_i_should_see_only_the_short_personal_statement

    when_i_click_show_more
    then_i_should_see_the_whole_personal_statement
    when_i_click_show_less
    then_i_should_see_only_the_short_personal_statement
  end

  def given_i_have_an_unsubmitted_application_with_short_personal_statement
    @application_form.update!(becoming_a_teacher: short_personal_statement)
    @application_choice = create(:application_choice, :unsubmitted, application_form: @application_form)
  end

  def given_i_have_an_unsubmitted_application_with_long_personal_statement
    @application_form.update!(becoming_a_teacher: long_personal_statement)
    @application_choice = create(:application_choice, :unsubmitted, application_form: @application_form)
  end

  def given_i_have_an_submitted_application_with_short_personal_statement
    @application_choice = create(:application_choice, :awaiting_provider_decision, application_form: @application_form, personal_statement: short_personal_statement)
  end

  def given_i_have_an_submitted_application_with_long_personal_statement
    @application_choice = create(:application_choice, :awaiting_provider_decision, application_form: @application_form, personal_statement: long_personal_statement)
  end

  def short_personal_statement
    'short personal statement'
  end

  def first_part_long_personal_statement
    number_of_words_to_display_the_show_more_link.times.map { 'long' }.join(' ')
  end

  def long_personal_statement
    "#{first_part_long_personal_statement} #{remaining_personal_statement}"
  end

  def remaining_personal_statement
    'remaining personal statement'
  end

  def then_i_should_see_the_full_personal_statement
    expect(page).to have_content(short_personal_statement)
  end

  def then_i_should_see_only_the_short_personal_statement
    expect(page).to have_content(first_part_long_personal_statement)
    expect(remaining_personal_statement_element[:class]).to eq('govuk-visually-hidden')
  end

  def when_i_click_show_more
    click_link_or_button 'Show more'
  end

  def then_i_should_see_the_whole_personal_statement
    expect(page).to have_content(first_part_long_personal_statement)
    expect(remaining_personal_statement_element[:class]).not_to include('govuk-visually-hidden')
  end

  def when_i_click_show_less
    click_link_or_button 'Show less'
  end

  def number_of_words_to_display_the_show_more_link
    CandidateInterface::ContinuousApplications::PersonalStatementSummaryComponent::MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT
  end

  def remaining_personal_statement_element
    page.find(id: 'app-remaining-personal-statement')
  end
end

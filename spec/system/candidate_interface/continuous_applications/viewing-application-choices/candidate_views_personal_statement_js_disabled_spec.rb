require 'rails_helper'

RSpec.describe 'Personal statement' do
  include CandidateHelper

  before do
    create_and_sign_in_candidate
    @application_form = create(:application_form, candidate: current_candidate)
  end

  scenario 'when application is unsubmitted and showing full personal statement' do
    given_i_have_an_unsubmitted_application_with_long_personal_statement
    when_i_visit_my_applications
    when_i_click_to_view_my_application
    then_i_should_see_the_full_personal_statement
  end

  def given_i_have_an_unsubmitted_application_with_long_personal_statement
    @application_form.update!(becoming_a_teacher: long_personal_statement)
    @application_choice = create(:application_choice, :unsubmitted, application_form: @application_form)
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
    expect(page).to have_content(long_personal_statement)
  end

  def number_of_words_to_display_the_show_more_link
    CandidateInterface::ContinuousApplications::PersonalStatementSummaryComponent::MAXIMUM_WORDS_FULL_PERSONAL_STATEMENT
  end
end

require 'rails_helper'

RSpec.describe 'Carry over equality and diversity data', time: CycleTimetableHelper.mid_cycle(2024) do
  include CandidateHelper

  before do
    @candidate = create(:candidate)
    @application_form = create(:application_form, :completed, candidate: @candidate)
  end

  scenario 'Candidate has incompatible equality and diversity data in existing application' do
    given_i_have_an_application_with_incompatible_equality_and_diversity_data_from_last_cycle
    and_i_sign_in
    when_i_choose_to_continue_my_application
    then_the_equality_and_diversity_section_is_marked_as_incomplete

    when_i_edit_the_equality_and_diversity_section
    then_i_do_not_have_the_option_to_complete_the_section
  end

  scenario 'Candidate has valid but incomplete equality and diversity data in existing application' do
    given_i_have_an_application_with_valid_but_incomplete_equality_and_diversity_data
    and_i_sign_in
    when_i_choose_to_continue_my_application
    then_the_equality_and_diversity_section_is_marked_as_incomplete

    when_i_edit_the_equality_and_diversity_section
    then_i_do_not_have_the_option_to_complete_the_section
  end

  scenario 'Candidate has selected "prefer not to say" for all questions' do
    given_i_have_an_application_with_prefer_not_to_say_selected_for_all_equality_and_diversity_questions
    and_i_sign_in
    when_i_choose_to_continue_my_application
    then_the_equality_and_diversity_section_is_marked_as_complete

    when_i_edit_the_equality_and_diversity_section
    then_i_see_the_option_to_complete_the_section
  end

private

  def given_i_have_an_application_with_prefer_not_to_say_selected_for_all_equality_and_diversity_questions
    @application_form.update!(submitted_at: nil,
                              recruitment_cycle_year: RecruitmentCycle.previous_year,
                              equality_and_diversity_completed: true,
                              equality_and_diversity: { sex: 'Prefer not to say',
                                                        disabilities: 'Prefer not to say',
                                                        ethnic_background: 'Prefer not to say' })
  end

  def given_i_have_an_application_with_incompatible_equality_and_diversity_data_from_last_cycle
    @application_form.update!(submitted_at: nil,
                              recruitment_cycle_year: RecruitmentCycle.previous_year,
                              equality_and_diversity_completed: true,
                              equality_and_diversity: { sex: 'sex',
                                                        hesa_sex: nil,
                                                        hesa_ethnicity: nil,
                                                        hesa_disabilities: ['96'],
                                                        disabilities: ['disability'],
                                                        ethnic_group: 'nothing here',
                                                        ethnic_background: 'd' })
  end

  def given_i_have_an_application_with_valid_but_incomplete_equality_and_diversity_data
    @application_form.update!(submitted_at: nil,
                              recruitment_cycle_year: RecruitmentCycle.previous_year,
                              equality_and_diversity_completed: true,
                              equality_and_diversity: { sex: 'female',
                                                        disabilities: 'Prefer not to say' })
  end

  def and_i_sign_in
    login_as(@candidate)
    visit root_path
  end

  def when_i_choose_to_continue_my_application
    click_on 'Continue'
  end

  def then_the_equality_and_diversity_section_is_marked_as_incomplete
    expect(find_by_id('equality-and-diversity-questions-badge-id').text).to eq('Incomplete')
  end

  def then_the_equality_and_diversity_section_is_marked_as_complete
    expect(find_by_id('equality-and-diversity-questions-badge-id').text).to eq('Completed')
  end

  def when_i_edit_the_equality_and_diversity_section
    click_on 'Equality and diversity questions'
  end

  def then_i_do_not_have_the_option_to_complete_the_section
    expect(page).to have_no_content 'Check your answers'
    expect(page).to have_content 'What is your sex?'
  end

  def then_i_see_the_option_to_complete_the_section
    expect(page).to have_content 'Check your answers'
    expect(page).to have_no_content 'What is your sex?'
  end
end

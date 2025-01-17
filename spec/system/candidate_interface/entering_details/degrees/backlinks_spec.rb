require 'rails_helper'

RSpec.describe 'Degrees' do
  include CandidateHelper

  scenario 'Candidate editing degree' do
    given_i_am_signed_in_with_one_login
    and_i_have_completed_the_degree_section
    when_i_view_the_degree_section
    and_i_click_to_change_my_undergraduate_degree_type
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_degree_review_page

    when_i_click_to_change_my_undergraduate_degree_type
    and_i_click_on_save_and_continue
    then_i_am_taken_to_the_specific_degree_type_page
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_degree_type_page
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_degree_review_page

    when_i_click_to_change_my_completion_status
    and_i_click_on_save_and_continue
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_degree_complete_page
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_degree_review_page

    when_i_click_to_change_my_university
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_degree_review_page

    when_i_click_to_change_my_country
    and_i_choose_another_country
    and_i_click_on_save_and_continue
    and_i_fill_the_type_of_degree
    and_i_click_on_save_and_continue
    and_i_fill_in_a_subject
    and_i_click_on_save_and_continue
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_subject_page
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_type_page
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_country_page
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_university_degree_page
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_degree_review_page

    given_that_i_have_a_completed_international_degree
    when_i_view_the_degree_section
    and_i_click_to_change_my_undergraduate_degree_completion_status
    when_i_choose_yes
    and_i_click_on_save_and_continue
    then_i_am_taken_to_the_award_year_page
    and_i_fill_out_the_year
    and_i_click_on_save_and_continue
    then_i_am_taken_to_the_enic_page
    and_i_click_the_back_link
    then_i_am_taken_to_the_award_year_page
    and_i_click_the_back_link
    then_i_am_taken_to_the_degree_complete_page
    and_i_click_the_back_link
    then_i_am_taken_back_to_the_degree_review_page
  end

  def and_i_have_completed_the_degree_section
    @application_form = create(:application_form, candidate: @current_candidate)
    create(:application_qualification,
           level: 'degree',
           qualification_type: 'Bachelor of Arts',
           start_year: '2006',
           award_year: '2009',
           predicted_grade: false,
           subject: 'Computer Science',
           institution_name: 'University of Cambridge',
           institution_country: nil,
           grade: 'A',
           application_form: @application_form)
    @application_form.update!(degrees_completed: true)
  end

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    when_i_click_on_degree
  end
  alias_method :when_the_user_visits_degree_section_using_address_bar, :when_i_view_the_degree_section

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end

  def and_i_click_to_change_my_undergraduate_degree_type
    click_change_link('qualification')
  end

  def and_i_click_the_back_link
    click_link_or_button 'Back'
  end

  def then_i_am_taken_back_to_the_degree_review_page
    expect(page).to have_content('Degree')
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def then_i_am_taken_to_the_specific_degree_type_page
    expect(page).to have_content 'What type of bachelor degree is it?'
  end

  def when_i_click_to_change_my_undergraduate_degree_type
    click_change_link('qualification')
  end

  def then_i_am_taken_back_to_the_degree_type_page
    expect(page).to have_content 'What type of degree is it?'
  end

  def when_i_click_to_change_my_completion_status
    click_change_link('completion status')
  end

  def then_i_am_taken_back_to_the_degree_complete_page
    expect(page).to have_content 'Have you completed your degree?'
  end

  def when_i_click_to_change_my_university
    click_change_link('institution')
  end

  def when_i_click_to_change_my_country
    click_change_link('country')
  end

  def and_i_choose_another_country
    choose 'Another country'
    select 'France'
  end

  def and_i_fill_the_type_of_degree
    fill_in 'candidate_interface_degree_wizard[international_type]', with: 'Bachelor'
  end

  def and_i_fill_in_a_subject
    select 'History', from: 'candidate_interface_degree_wizard[subject]'
  end

  def then_i_am_taken_back_to_the_subject_page
    expect(page).to have_content('What subject is your degree?')
  end

  def then_i_am_taken_back_to_the_type_page
    expect(page).to have_content('What type of degree is it?')
  end

  def then_i_am_taken_back_to_the_country_page
    expect(page).to have_content('Which country was the degree from?')
  end

  def given_that_i_have_a_completed_international_degree
    create(:application_qualification,
           level: 'degree',
           qualification_type: 'Diplome',
           start_year: '2006',
           award_year: '2009',
           predicted_grade: true,
           subject: 'History',
           institution_name: 'University of Paris',
           institution_country: 'FR',
           grade: '94%',
           international: true,
           application_form: @application_form)
    @application_form.update!(degrees_completed: true)
  end

  def and_i_click_to_change_my_undergraduate_degree_completion_status
    completion_status_row = find('.govuk-summary-list__row', text: 'completion status', match: :first)
    within completion_status_row do
      click_change_link('completion status')
    end
  end

  def when_i_choose_yes
    choose 'Yes'
  end

  def then_i_am_taken_to_the_award_year_page
    expect(page).to have_content 'What year did you graduate?'
  end

  def and_i_fill_out_the_year
    fill_in 'What year did you graduate?', with: '2009'
  end

  def then_i_am_taken_to_the_enic_page
    expect(page).to have_content 'Show how your degree compares to a UK degree'
  end

  def then_i_am_taken_to_the_degree_complete_page
    expect(page).to have_content 'Have you completed your degree?'
  end

  def then_i_am_taken_back_to_the_university_degree_page
    expect(page).to have_current_path(candidate_interface_degree_university_degree_path)
  end

  def when_i_visit_the_application_review_page
    visit candidate_interface_application_review_path
  end
  alias_method :when_i_visit_the_application_review_page_using_address_bar, :when_i_visit_the_application_review_page

  def and_i_click_to_change_my_university_again
    university_row = find('.govuk-summary-list__row', text: 'institution', match: :first)
    within university_row do
      click_change_link('institution')
    end
  end

  def and_i_click_to_change_my_subject
    subject_row = find('.govuk-summary-list__row', text: 'subject', match: :first)
    within subject_row do
      click_change_link('subject')
    end
  end
end

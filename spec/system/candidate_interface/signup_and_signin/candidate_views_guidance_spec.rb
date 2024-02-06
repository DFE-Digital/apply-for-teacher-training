require 'rails_helper'

RSpec.feature 'Candidate visits the sign-in page and views guidance' do
  scenario 'User can open the guidance page with dates for the current recruitment cycle year' do
    and_the_recruitment_cycle_year_is_2024
    and_i_visit_the_sign_in_page
    and_i_click_on_the_guidance_link
    then_i_am_taken_to_the_guidance_page
    and_i_can_see_the_correct_dates
  end

  def and_the_recruitment_cycle_year_is_2024
    allow(CycleTimetable).to receive(:current_year).and_return(2024)
  end

  def and_i_visit_the_sign_in_page
    visit candidate_interface_create_account_or_sign_in_path
  end

  def and_i_click_on_the_guidance_link
    click_link_or_button 'Read how the application process works'
  end

  def then_i_am_taken_to_the_guidance_page
    expect(page).to have_current_path(candidate_interface_guidance_path)
  end

  def and_i_can_see_the_correct_dates
    expect(page).to have_content('The application process for courses starting in September 2024')
    expect(page).to have_content('3 October 2023 at 9am')
    expect(page).to have_content('Start finding postgraduate teacher training courses')
    expect(page).to have_content("10 October 2023 at 9am\nStart applying to courses.")
    expect(page).to have_content('17 September 2024 at 6pmThe last day to submit any applications.')
    expect(page).to have_content('25 September 2024 at 11:59pm')
    expect(page).to have_content('The last day for training providers to make a decision on all applications for courses starting in September 2024')
  end
end

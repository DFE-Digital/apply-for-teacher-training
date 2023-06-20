require 'rails_helper'

RSpec.feature 'Candidate visits the sign-in page and views guidance' do
  scenario 'User can open the guidance page with dates for the current recruitment cycle year' do
    when_the_continuous_applications_feature_is_enabled
    and_the_recruitment_cycle_year_is_2024
    and_i_visit_the_sign_in_page
    and_i_click_on_the_guidance_link
    then_i_am_taken_to_the_guidance_page
    and_i_can_see_the_correct_dates
  end

  def when_the_continuous_applications_feature_is_enabled
    FeatureFlag.activate(:continuous_applications)
  end

  def and_the_recruitment_cycle_year_is_2024
    allow(CycleTimetable).to receive(:current_year).and_return(2024)
  end

  def and_i_visit_the_sign_in_page
    visit candidate_interface_create_account_or_sign_in_path
  end

  def and_i_click_on_the_guidance_link
    click_link 'Read how the application process works'
  end

  def then_i_am_taken_to_the_guidance_page
    expect(page).to have_current_path(candidate_interface_guidance_path)
  end

  def and_i_can_see_the_correct_dates
    expect(page).to have_content('The application process for courses starting in September 2024')
    expect(page).to have_content('3 October 2023 at 9am Start finding postgraduate teacher training courses')
    expect(page).to have_content("10 October 2023 at 9am\nStart applying to courses.")
    expect(page).to have_content('1 July 2024 The time training providers have to make a decision about your application is reduced from 30 working days to 20 working days.')
    expect(page).to have_content("3 September 2024 at 6pm\nIf you have not already applied for teacher training, you will not be able to apply after 3 September 2024")
    expect(page).to have_content('25 September 2024 at 11:59pm The last day for training providers to make a decision')
  end
end

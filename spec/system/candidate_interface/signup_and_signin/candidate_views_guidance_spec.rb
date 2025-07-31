require 'rails_helper'

RSpec.describe 'User visits the sign-in page and views guidance' do
  scenario 'User visits the guidance page with dates for the current recruitment cycle year', time: after_find_opens(2025) do
    when_i_visit_the_guidance_page
    then_i_can_see_the_correct_dates
  end

  def when_i_visit_the_guidance_page
    visit candidate_interface_guidance_path
    expect(page).to have_content('The application process for courses starting in September 2025')
  end

  def then_i_can_see_the_correct_dates
    expect(page).to have_content('The application process for courses starting in September 2025')
    expect(page).to have_content('1 October 2024 at 9am UK time')
    expect(page).to have_content('Start finding postgraduate teacher training courses')
    expect(page).to have_content('8 October 2024 at 9am UK time')
    expect(page).to have_content('16 September 2025 at 6pm UK time')
    expect(page).to have_content('24 September 2025 at 11:59pm UK time')
    expect(page).to have_content('The last day for training providers to make a decision on all applications for courses starting in September 2025')
  end
end

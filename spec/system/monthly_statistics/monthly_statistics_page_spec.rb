require 'rails_helper'

RSpec.feature 'Monthly statistics page' do
  scenario 'User visits monthly statistics page' do
    when_i_visit_the_monthly_statistics_page
    then_i_can_see_the_monthly_statistics
  end

  def when_i_visit_the_monthly_statistics_page
    visit '/monthly-statistics'
  end

  def then_i_can_see_the_monthly_statistics
    expect(page).to have_content 'Applicants for initial teacher training courses'
  end
end

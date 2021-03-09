require 'rails_helper'

RSpec.feature 'Data API docs' do
  scenario 'User visits Data API docs' do
    when_i_visit_the_data_api_docs
    then_i_can_see_the_docs
  end

  def when_i_visit_the_data_api_docs
    visit '/data-api'
  end

  def then_i_can_see_the_docs
    expect(page).to have_content 'Apply for teacher training data API'
  end
end

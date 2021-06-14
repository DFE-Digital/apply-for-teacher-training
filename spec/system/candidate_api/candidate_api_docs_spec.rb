require 'rails_helper'

RSpec.feature 'Candidate API docs' do
  scenario 'User visits Candidate API docs' do
    when_i_visit_the_candidate_api_docs
    then_i_can_see_the_docs
  end

  def when_i_visit_the_candidate_api_docs
    visit '/candidate-api'
  end

  def then_i_can_see_the_docs
    expect(page).to have_content 'Apply for teacher training candidate API'
  end
end

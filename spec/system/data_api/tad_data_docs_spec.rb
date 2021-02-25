require 'rails_helper'

RSpec.feature 'TAD data docs' do
  scenario 'User visits TAD data docs' do
    when_i_visit_the_tad_data_docs
    then_i_can_see_the_docs
  end

  def when_i_visit_the_tad_data_docs
    visit '/data-api/docs/tad-data-exports'
  end

  def then_i_can_see_the_docs
    expect(page).to have_content 'TAD export documentation'
  end
end

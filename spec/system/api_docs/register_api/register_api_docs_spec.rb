require 'rails_helper'

RSpec.feature 'Register API docs' do
  scenario 'User visits Register API docs' do
    when_i_visit_the_register_api_docs
    then_i_can_see_the_docs
    and_i_can_see_the_release_notes
  end

  def when_i_visit_the_register_api_docs
    visit '/register-api'
  end

  def then_i_can_see_the_docs
    expect(page).to have_content 'Apply for teacher training - Register API'
  end

  def and_i_can_see_the_release_notes
    click_link 'Release notes'
    expect(page).to have_content '7 April 2021'
  end
end

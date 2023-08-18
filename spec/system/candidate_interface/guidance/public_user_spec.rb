require 'rails_helper'

RSpec.describe 'Non logged in user can visit guidance' do
  scenario 'User can visit the guidance page without session' do
    visit(candidate_interface_guidance_path)
    expect(page).to have_content('Start applying for courses')
  end
end

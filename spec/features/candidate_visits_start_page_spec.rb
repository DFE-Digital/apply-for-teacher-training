require 'rails_helper'

describe 'Candidate visits start page' do
  it 'works' do
    visit '/'
    expect(page).to have_content(
      'Apply for postgraduate teacher training'
    )
  end
end

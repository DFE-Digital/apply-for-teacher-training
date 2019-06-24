require 'rails_helper'

describe 'Candidate visits start page' do
  it 'displays a summary of the service' do
    visit '/'
    expect(page).to have_content(
      'Apply for postgraduate teacher training is a new GOV.UK service'
    )
  end
end

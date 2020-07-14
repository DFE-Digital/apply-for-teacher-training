require 'rails_helper'

RSpec.describe 'GET apply-for-teacher-training.education.gov.uk', type: :request do
  it 'redirects to apply-for-teacher-training.service.gov.uk' do
    get 'https://www.apply-for-teacher-training.education.gov.uk/'
    expect(response.location).to eq('https://www.apply-for-teacher-training.service.gov.uk/')
  end
end

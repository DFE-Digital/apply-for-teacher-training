require 'rails_helper'

RSpec.describe 'GET course_choices/go_to_find' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  it 'is a successful request' do
    get candidate_interface_course_choices_go_to_find_explanation_path

    expect(response).to have_http_status(:success)
  end
end

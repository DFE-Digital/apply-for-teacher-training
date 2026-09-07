require 'rails_helper'

RSpec.describe 'GET course_choices/go_to_find' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  context 'mid_cycle', time: mid_cycle do
    it 'is a successful request mid cycle' do
      get candidate_interface_course_choices_go_to_find_explanation_path

      expect(response).to have_http_status(:success)
    end
  end

  context 'after_apply_deadline', time: after_apply_deadline do
    it 'redirects after the apply deadline' do
      get candidate_interface_course_choices_go_to_find_explanation_path

      expect(response).to have_http_status(:redirect)
    end
  end
end

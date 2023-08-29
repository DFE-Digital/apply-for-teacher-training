require 'rails_helper'

RSpec.describe 'continuous applications redirects', continuous_applications: true do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  describe 'choose' do
    it 'redirects choose to continuous applications' do
      get candidate_interface_course_choices_choose_path

      expect(response).to redirect_to(candidate_interface_continuous_applications_do_you_know_the_course_path)
    end
  end

  describe 'find' do
    it 'redirects find to continuous applications' do
      get candidate_interface_go_to_find_path

      expect(response).to redirect_to(candidate_interface_continuous_applications_go_to_find_explanation_path)
    end
  end
end

require 'rails_helper'

RSpec.describe 'CandidateInterface::GCSE::TypeController', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create :candidate }

  before { sign_in candidate }

  describe 'edit' do
    it 'redirects if qualification not created yet' do
      %w[maths english science].each do |subject|
        get "/candidate/application/gcse/#{subject}/edit"

        expect(response).to redirect_to candidate_interface_application_form_path
      end
    end
  end

  describe 'update' do
    it 'redirects if qualification not created yet' do
      %w[maths english science].each do |subject|
        patch "/candidate/application/gcse/#{subject}/edit"

        expect(response).to redirect_to candidate_interface_application_form_path
      end
    end
  end
end

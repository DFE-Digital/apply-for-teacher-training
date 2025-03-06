require 'rails_helper'

RSpec.describe 'Candidate Interface - adviser sign up availability' do
  include Devise::Test::IntegrationHelpers

  subject do
    perform_request
    response
  end

  shared_context 'send requests' do
    describe '#new' do
      let(:perform_request) { get new_candidate_interface_adviser_sign_up_path }

      it { is_expected.to have_http_status(expected_http_status) }
    end

    describe '#create' do
      let(:perform_request) { post candidate_interface_adviser_sign_ups_path }

      it { is_expected.to have_http_status(expected_http_status) }
    end
  end

  context 'when eligible for adviser sign up' do
    let(:application_form) { create(:application_form_eligible_for_adviser, adviser_status: 'unassigned') }
    let(:expected_http_status) { :success }

    include_context 'send requests'
  end

  context 'when ineligible for adviser sign up' do
    let(:application_form) { create(:application_form) }
    let(:expected_http_status) { :not_found }

    include_context 'send requests'
  end
end

require 'rails_helper'

RSpec.describe 'Candidate Interface - adviser sign up availability' do
  include_context 'get into teaching api stubbed endpoints'

  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }
  let(:application_form) { create(:application_form_eligible_for_adviser, candidate:) }

  before do
    FeatureFlag.activate(:adviser_sign_up)
    sign_in application_form.candidate
  end

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

  context 'when eligible for an adviser and feature flag is active' do
    let(:expected_http_status) { :success }

    include_context 'send requests'
  end

  context 'when eligible for an adviser and feature flag is deactivated' do
    before { FeatureFlag.deactivate(:adviser_sign_up) }

    let(:expected_http_status) { :not_found }

    include_context 'send requests'
  end

  context 'when ineligible for an adviser and feature flag is active' do
    before { application_form.application_qualifications.degrees.destroy_all }

    let(:expected_http_status) { :not_found }

    include_context 'send requests'
  end
end

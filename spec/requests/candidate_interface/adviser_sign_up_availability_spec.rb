require 'rails_helper'

RSpec.describe 'Candidate Interface - adviser sign up availability' do
  include_context 'get into teaching api stubbed endpoints'

  include Devise::Test::IntegrationHelpers

  let(:application_form) { create(:application_form_eligible_for_adviser) }

  before do
    availability_double = instance_double(Adviser::SignUpAvailability, eligible_and_unassigned_a_teaching_training_adviser?: available)
    allow(Adviser::SignUpAvailability).to receive(:new).and_return(availability_double)

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

  context 'when eligible for adviser sign up' do
    let(:available) { true }
    let(:expected_http_status) { :success }

    include_context 'send requests'
  end

  context 'when ineligible for adviser sign up' do
    let(:available) { false }
    let(:expected_http_status) { :not_found }

    include_context 'send requests'
  end
end

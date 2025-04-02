require 'rails_helper'

RSpec.describe 'Candidate Interface - adviser sign up availability' do
  include Devise::Test::IntegrationHelpers

  subject do
    sign_in application_form.candidate
    perform_request
    response
  end

  let(:preferred_teaching_subject_id) { create(:adviser_teaching_subject, title: 'Chemistry', external_identifier: 'CH3').external_identifier }

  shared_context 'send requests' do
    describe '#show' do
      let(:perform_request) { get candidate_interface_adviser_sign_up_path(application_form.id, preferred_teaching_subject_id:) }
      let(:expected_http_status) { application_form.eligible_to_sign_up_for_a_teaching_training_adviser? ? :success : :not_found }

      it { is_expected.to have_http_status(expected_http_status) }
    end

    describe '#new' do
      let(:perform_request) { get new_candidate_interface_adviser_sign_up_path(application_form_id: application_form.id, preferred_teaching_subject_id:) }
      let(:expected_http_status) { application_form.eligible_to_sign_up_for_a_teaching_training_adviser? ? :success : :not_found }

      it { is_expected.to have_http_status(expected_http_status) }
    end

    describe '#continue' do
      let(:perform_request) do
        post continue_candidate_interface_adviser_sign_ups_path, params: { adviser_sign_up: { preferred_teaching_subject_id: preferred_teaching_subject_id } }
      end
      let(:expected_http_status) { application_form.eligible_to_sign_up_for_a_teaching_training_adviser? ? :found : :not_found }

      it { is_expected.to have_http_status(expected_http_status) }
    end

    describe '#create' do
      let(:perform_request) do
        post candidate_interface_adviser_sign_ups_path, params: { adviser_sign_up: { preferred_teaching_subject_id: preferred_teaching_subject_id } }
      end
      let(:expected_http_status) { application_form.eligible_to_sign_up_for_a_teaching_training_adviser? ? :found : :not_found }

      it { is_expected.to have_http_status(expected_http_status) }
    end
  end

  context 'when eligible for adviser sign up' do
    let(:application_form) { create(:application_form_eligible_for_adviser, adviser_status: 'unassigned') }

    include_context 'send requests'
  end

  context 'when ineligible for adviser sign up' do
    let(:application_form) { create(:application_form) }

    include_context 'send requests'
  end
end

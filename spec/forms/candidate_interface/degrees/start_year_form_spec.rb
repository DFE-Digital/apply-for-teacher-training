require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::StartYearForm do
  subject(:start_year_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    context 'start_year presence' do
      let(:degree_params) { { start_year: nil } }

      it 'returns the correct error message' do
        expect(start_year_form.valid?).to be false
        expect(start_year_form.errors[:start_year]).to eq ['Enter your start year']
      end
    end

    context 'start_year is after award year' do
      let(:degree_params) { { start_year: '2024', award_year: '2023' } }

      it 'returns the correct error message' do
        expect(start_year_form.valid?).to be false
        expect(start_year_form.errors[:start_year]).to eq ['Enter a start year before your graduation year']
      end
    end

    context 'start_year is not in the future if degree completed' do
      let(:degree_params) { { start_year: Time.zone.now.year + 1, completed: 'Yes' } }

      it 'returns the correct error message' do
        expect(start_year_form.valid?).to be false
        expect(start_year_form.errors[:start_year]).to eq ['Enter a start year in the past']
      end
    end
  end

  describe 'next_step' do
    context 'reviewing and country unchanged' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'NG').id,
          country: 'NG',
        }
      end

      it 'returns review' do
        expect(start_year_form.next_step).to eq :review
      end
    end

    context 'reviewing and country changed' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB').id,
          country: 'NG',
        }
      end

      it 'returns award year' do
        expect(start_year_form.next_step).to eq :award_year
      end
    end
  end

  describe 'back_link' do
    context 'reviewing and country unchanged' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'NG').id,
          country: 'NG',
        }
      end

      it 'returns review' do
        expect(start_year_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_review_path
      end
    end

    context 'reviewing and country changed and phd' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'NG').id,
          country: 'AU',
          degree_level: 'doctor',
        }
      end

      it 'returns degree completed path' do
        expect(start_year_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_completed_path
      end
    end

    context 'not a phd' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'NG').id,
          country: 'AU',
          degree_level: 'bachelor',
        }
      end

      it 'returns degree grade path' do
        expect(start_year_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_grade_path
      end
    end
  end
end

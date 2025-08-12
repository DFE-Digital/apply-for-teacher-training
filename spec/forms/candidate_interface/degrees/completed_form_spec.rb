require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::CompletedForm do
  subject(:completed_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    context 'validates completed presence' do
      let(:degree_params) { { completed: nil } }

      it 'returns the correct validation message' do
        expect(completed_form.valid?).to be false
        expect(completed_form.errors[:completed]).to eq ['Select whether you have completed your degree']
      end
    end
  end

  describe 'back_link' do
    context 'reviewing with an country unchanged' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB'),
          country: 'GB',
        }
      end

      it 'returns review path' do
        expect(completed_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_review_path
      end
    end

    context 'reviewing with changed country' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB'),
          country: 'NG',
        }
      end

      it 'returns path for do you have a degree' do
        expect(completed_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_university_path
      end
    end
  end

  describe 'next_step' do
    context 'reviewing, unchanged country' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'AU'),
          country: 'AU',
        }
      end

      it 'returns the review step' do
        expect(completed_form.next_step).to eq(:award_year)
      end
    end

    context 'reviewing, country has changed' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB'),
          country: 'AU',
          degree_level: 'doctor',
        }
      end

      it 'returns start year (ie, skips grade for PhD)' do
        expect(completed_form.next_step).to eq(:start_year)
      end
    end

    context 'reviewing, country changed, undergraduate degree' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB'),
          country: 'AU',
          degree_level: 'bachelor',
        }
      end

      it 'returns grade (ie, new grade because country has changed)' do
        expect(completed_form.next_step).to eq(:grade)
      end
    end

    context 'not reviewing, not phd' do
      let(:degree_params) do
        {
          degree_level: 'bachelor',
        }
      end

      it 'returns start year (ie, skips grade)' do
        expect(completed_form.next_step).to eq(:grade)
      end
    end
  end
end

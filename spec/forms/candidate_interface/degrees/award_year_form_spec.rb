require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::AwardYearForm do
  subject(:award_year_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    describe 'award year present' do
      let(:degree_params) { { award_year: nil } }

      it 'returns the correct validation message' do
        expect(award_year_form.valid?).to be false
        expect(award_year_form.errors[:award_year]).to eq ['Enter your graduation year']
      end
    end

    describe 'award_year_is_before_start_year' do
      let(:degree_params) { { completed: 'Yes', start_year: Time.zone.now.year, award_year: 2.years.ago.year } }

      it 'returns the correct validation message' do
        expect(award_year_form.valid?).to be false
        expect(award_year_form.errors[:award_year]).to eq ['Enter a graduation year after your start year']
      end
    end

    describe 'award_year_in_future_when_degree_completed' do
      let(:degree_params) { { completed: 'Yes', start_year: 1.year.ago.year, award_year: 2.years.from_now.year } }

      it 'returns the correct validation message' do
        expect(award_year_form.valid?).to be false
        expect(award_year_form.errors[:award_year]).to eq ['Enter an award year in the past']
      end
    end

    describe 'award_year_in_past_when_degree_incomplete' do
      let(:degree_params) do
        {
          completed: 'No',
          start_year: 2.years.ago.year,
          award_year: 1.year.ago.year,
          application_form_id: application_form.id,
        }
      end

      it 'returns the correct validation message' do
        expect(award_year_form.valid?).to be false
        expect(award_year_form.errors[:award_year]).to eq ['Enter a year that is the current year or a year in the future']
      end
    end

    describe 'award_year_after_teacher_training_starts' do
      let(:degree_params) do
        {
          completed: 'No',
          start_year: 2.years.ago.year,
          award_year: current_year + 1,
          application_form_id: application_form.id,
        }
      end

      it 'returns the correct validation message' do
        expect(award_year_form.valid?).to be false
        expect(award_year_form.errors[:award_year]).to eq ['The date you graduate must be before the start of your teacher training']
      end
    end
  end

  describe 'back_link' do
    context 'reviewing and unchanged country' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'AU').id,
          country: 'AU',
        }
      end

      it 'returns the completed path' do
        expect(award_year_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_completed_path
      end
    end

    context 'reviewing and changed country' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'AU').id,
          country: 'GB',
        }
      end

      it 'returns the degree start year path' do
        expect(award_year_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_start_year_path
      end
    end

    context 'not reviewing' do
      let(:degree_params) { {} }

      it 'returns the degree start year path' do
        expect(award_year_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_start_year_path
      end
    end
  end

  describe 'next_step' do
    let(:degree_params) { { completed: 'Yes', uk_or_non_uk: 'non_uk' } }

    context 'completed and international' do
      it 'returns enic as the next step' do
        expect(award_year_form.next_step).to eq :enic
      end
    end

    context 'not international' do
      let(:degree_params) { { completed: 'Yes', uk_or_non_uk: 'uk' } }

      it 'returns review' do
        expect(award_year_form.next_step).to eq :review
      end
    end
  end
end

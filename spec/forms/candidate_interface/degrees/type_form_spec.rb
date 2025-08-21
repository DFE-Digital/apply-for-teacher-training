require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::TypeForm do
  subject(:wizard) { described_class.new(store, degree_params) }

  let(:degree_params) { {} }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before do
    allow(store).to receive(:read)
    allow(Sentry).to receive(:capture_exception)
  end

  describe '#next_step' do
    context 'reviewing and country is unchanged' do
      let(:degree_params) do
        {
          application_form_id: application_form.id,
          id: create(:degree_qualification, application_form:, institution_country: 'GB'),
          country: 'GB',
        }
      end

      it 'returns to review' do
        expect(wizard.next_step).to eq :review
      end
    end

    context 'reviewing and country has changed' do
      let(:degree_params) do
        {
          application_form_id: application_form.id,
          id: create(:degree_qualification, application_form:, institution_country: 'GB'),
          country: 'NG',
        }
      end

      it 'goes to subject step' do
        expect(wizard.next_step).to eq :subject
      end
    end
  end

  describe '#back_link' do
    context 'reviewing and unchanged country' do
      let(:degree_params) do
        {
          application_form_id: application_form.id,
          id: create(:degree_qualification, application_form:, institution_country: 'GB'),
          country: 'GB',
        }
      end

      it 'returns to review' do
        expect(wizard.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_review_path
      end
    end

    context 'country with compatible degrees' do
      let(:degree_params) do
        {
          country: ApplicationQualification::COUNTRIES_WITH_COMPATIBLE_DEGREES.keys.sample,
        }
      end

      it 'returns to degree level step' do
        expect(wizard.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_degree_level_path
      end
    end

    context 'country is uk' do
      let(:degree_params) do
        {
          uk_or_non_uk: 'uk',
          country: 'GB',
        }
      end

      it 'returns to degree level step' do
        expect(wizard.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_degree_level_path
      end
    end

    context 'other country, not uk or one with compatible degrees' do
      let(:degree_params) do
        {
          country: 'BB',
        }
      end

      it 'returns to country step' do
        expect(wizard.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_country_path
      end
    end
  end

  describe '#other_type' do
    let(:degree_params) do
      {
        other_type: 'Bachelor of Games',
        other_type_raw:,
      }
    end

    context 'when other type raw is present' do
      let(:other_type_raw) { 'Bachelor' }

      it 'returns raw value' do
        expect(wizard.other_type).to eq(other_type_raw)
      end
    end

    context 'when other type raw is empty' do
      let(:other_type_raw) { '' }

      it 'returns raw value' do
        expect(wizard.other_type).to eq(other_type_raw)
      end
    end

    context 'when other type raw is nil' do
      let(:other_type_raw) { nil }

      it 'returns original value' do
        expect(wizard.other_type).to eq('Bachelor of Games')
      end
    end
  end
end

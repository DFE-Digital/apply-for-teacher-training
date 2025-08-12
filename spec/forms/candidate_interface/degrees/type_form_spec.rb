require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::TypeForm do
  subject(:type_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before do
    allow(store).to receive(:read)
  end

  describe 'validations' do
    context 'type presence' do
      let(:degree_params) { { type: nil } }

      it 'returns the correct validation message' do
        expect(type_form.valid?).to be false
        expect(type_form.errors[:type]).to eq ['Select your degree type']
      end
    end

    context 'type free text too long' do
      let(:degree_params) { { type: Faker::Lorem.sentence(word_count: 256) } }

      it 'returns the correct validation message' do
        expect(type_form.valid?).to be false
        expect(type_form.errors[:type]).to eq ['Your degree type must be 255 characters or fewer']
      end
    end

    context 'other_type, presence if other selected' do
      let(:degree_params) { { type: 'other', other_type: nil, other_type_raw: nil } }

      it 'returns the correct validation message' do
        expect(type_form.valid?).to be false
        expect(type_form.errors[:other_type]).to eq ['Enter another degree type']
      end
    end

    context 'other_type, length if required and too long' do
      let(:degree_params) { { type: 'other', other_type: nil, other_type_raw: Faker::Lorem.sentence(word_count: 256) } }

      it 'returns the correct validation message' do
        expect(type_form.valid?).to be false
        expect(type_form.errors[:other_type]).to eq ['Your degree type must be 255 characters or fewer']
      end
    end
  end

  describe 'sanitize_attrs' do
    # This method is called by the parent class when the class is initialized.
    context 'type is not other' do
      let(:degree_params) do
        {
          type: 'Bachelor of Arts',
          other_type: 'Bachelor of Technology',
          other_type_raw: 'Something else entirely',
        }
      end

      it 'clears the other_type and other_type_raw' do
        expect(type_form.type).to eq 'Bachelor of Arts'
        expect(type_form.other_type).to be_nil
        expect(type_form.other_type_raw).to be_nil
      end
    end

    context 'type is other' do
      let(:degree_params) do
        {
          type: 'other',
          other_type: 'Bachelor of Technology',
          other_type_raw: nil,
        }
      end

      it 'retains the other type attributes' do
        expect(type_form.type).to eq 'other'
        expect(type_form.other_type).to eq 'Bachelor of Technology'
        expect(type_form.other_type_raw).to be_nil
      end
    end
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
        expect(type_form.next_step).to eq :review
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
        expect(type_form.next_step).to eq :subject
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
        expect(type_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_review_path
      end
    end

    context 'country with compatible degrees' do
      let(:degree_params) do
        {
          country: ApplicationQualification::COUNTRIES_WITH_COMPATIBLE_DEGREES.keys.sample,
        }
      end

      it 'returns to degree level step' do
        expect(type_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_degree_level_path
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
        expect(type_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_degree_level_path
      end
    end

    context 'other country, not uk or one with compatible degrees' do
      let(:degree_params) do
        {
          country: 'BB',
        }
      end

      it 'returns to country step' do
        expect(type_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_country_path
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
        expect(type_form.other_type).to eq(other_type_raw)
      end
    end

    context 'when other type raw is empty' do
      let(:other_type_raw) { '' }

      it 'returns raw value' do
        expect(type_form.other_type).to eq(other_type_raw)
      end
    end

    context 'when other type raw is nil' do
      let(:other_type_raw) { nil }

      it 'returns original value' do
        expect(type_form.other_type).to eq('Bachelor of Games')
      end
    end
  end
end

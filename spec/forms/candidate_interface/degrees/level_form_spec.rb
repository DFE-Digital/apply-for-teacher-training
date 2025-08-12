require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::LevelForm do
  subject(:level_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    context 'degree level presence' do
      let(:degree_params) { { degree_level: nil, equivalent_level: nil } }

      it 'returns the expected error message' do
        expect(level_form.valid?).to be false
        expect(level_form.errors[:degree_level]).to eq ['Select your degree type']
        expect(level_form.errors[:equivalent_level]).to eq []
      end
    end

    context 'equivalent level present, uk and other selected' do
      let(:degree_params) { { degree_level: 'other', equivalent_level: nil, uk_or_non_uk: 'uk' } }

      it 'returns the expected error message' do
        expect(level_form.valid?).to be false
        expect(level_form.errors[:equivalent_level]).to eq ['Enter your equivalent degree qualification type']
        expect(level_form.errors[:degree_level]).to eq []
      end
    end

    context 'equivalent level, other selected and not uk' do
      let(:degree_params) { { degree_level: 'other', equivalent_level: nil, uk_or_non_uk: 'non_uk' } }

      it 'is valid' do
        expect(level_form.valid?).to be true
      end
    end
  end

  describe 'sanitize_attrs' do
    # This method is called by the parent class on initialisation
    context 'when degree level is not other' do
      let(:degree_params) do
        { degree_level: 'bachelor',
          equivalent_level: 'something else'  }
      end

      it 'sets equivalent level to nil' do
        expect(level_form.equivalent_level).to be_nil
        expect(level_form.degree_level).to eq 'bachelor'
      end
    end

    context 'when degree level is other' do
      let(:degree_params) do
        { degree_level: 'other',
          equivalent_level: 'something else'  }
      end

      it 'des not change equivalent_level' do
        expect(level_form.equivalent_level).to eq 'something else'
        expect(level_form.degree_level).to eq 'other'
      end
    end
  end

  describe 'degree_level_options' do
    context 'international, but with compatible degrees' do
      let(:degree_params) do
        {
          uk_or_non_uk: 'non_uk',
          country: ApplicationQualification::COUNTRIES_WITH_COMPATIBLE_DEGREES.keys.sample,
        }
      end

      it 'returns only bachelor and other' do
        expect(level_form.degree_level_options).to eq %w[bachelor other]
      end
    end

    context 'uk' do
      let(:degree_params) { { uk_or_non_uk: 'uk', country: 'GB' } }

      it 'returns all uk degree options' do
        expect(level_form.degree_level_options).to eq ['foundation', 'bachelor', 'master', 'doctor', 'Level 6 Diploma', 'other']
      end
    end
  end

  describe 'back_link' do
    context 'reviewing and country not changed' do
      let(:degree_params) do
        { id: create(:degree_qualification, institution_country: 'GB', application_form:),
          country: 'GB'  }
      end

      it 'returns to review page' do
        expect(level_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_review_path
      end
    end

    context 'country changed and reviewing' do
      let(:degree_params) do
        { id: create(:degree_qualification, institution_country: 'GB', application_form:),
          country: 'NG'  }
      end

      it 'returns the degree country path' do
        expect(level_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_country_path
      end
    end
  end

  describe 'next_step' do
    context 'reviewing, level and country unchanged' do
      let(:degree_params) do
        { id: create(
          :degree_qualification,
          qualification_level: 'bachelor',
          institution_country: 'GB',
          application_form:,
        ),
          degree_level: 'bachelor',
          country: 'GB' }
      end

      it 'returns to type' do
        expect(level_form.next_step).to eq :type
      end
    end

    context 'reviewing, unchanged country, but degree level changed to something without a type' do
      let(:degree_params) do
        { id: create(
          :degree_qualification,
          qualification_level: 'bachelor',
          institution_country: 'GB',
          application_form:,
        ),
          degree_level: 'Level 6 Diploma',
          country: 'GB' }
      end

      it 'returns to review (ie, skips type)' do
        expect(level_form.next_step).to eq :review
      end
    end

    context 'not reviewing, and the chosen level does not require a type' do
      let(:degree_params) { { degree_level: 'Level 6 Diploma' } }

      it 'goes to subject (ie, skips type)' do
        expect(level_form.next_step).to eq :subject
      end
    end

    context 'reviewing, unchanged country, but degree level changed to something with a type' do
      let(:degree_params) do
        { id: create(
          :degree_qualification,
          qualification_level: 'bachelor',
          institution_country: 'GB',
          application_form:,
        ),
          degree_level: 'master',
          country: 'GB' }
      end

      it 'returns type' do
        expect(level_form.next_step).to eq :type
      end
    end
  end
end

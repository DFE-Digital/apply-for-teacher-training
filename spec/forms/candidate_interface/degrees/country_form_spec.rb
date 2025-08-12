require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::CountryForm do
  subject(:country_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before { allow(store).to receive(:read) }

  describe 'sanitize_attrs' do
    # This method is called by the parent class when the form is instantiated.
    context 'when uk_or_non_uk is set to uk' do
      let(:degree_params) { { uk_or_non_uk: 'uk' } }

      it 'sets country to GB' do
        expect(country_form.uk_or_non_uk).to eq 'uk'
        expect(country_form.country).to eq 'GB'
      end
    end

    context 'when country changes from non uk to uk' do
      let(:degree_params) { { uk_or_non_uk: 'uk', country: 'NG' } }

      it 'clears all degree details' do
        %i[degree_level equivalent_level type other_type subject completed university start_year award_year grade other_grade enic_reason enic_reference comparable_uk_degree].each do |attribute|
          expect(country_form.public_send(attribute)).to be_nil
        end
      end

      it 'sets country to GB' do
        expect(country_form.country).to eq 'GB'
      end
    end
  end

  describe 'validations' do
    context 'uk_or_non_uk_presence' do
      let(:degree_params) { { uk_or_non_uk: nil } }

      it 'returns the correct validation message' do
        expect(country_form.valid?).to be false
        expect(country_form.errors[:uk_or_non_uk]).to eq ['Select if the degree was from the United Kingdom or another country']
      end
    end

    context 'country presence' do
      let(:degree_params) { { uk_or_non_uk: 'non_uk', country: nil } }

      it 'returns the correct validation message' do
        expect(country_form.valid?).to be false
        expect(country_form.errors[:country]).to eq ['Select which country the degree was from']
      end
    end
  end

  describe 'back_link' do
    context 'reviewing' do
      let(:degree_params) { { id: create(:degree_qualification, application_form:).id } }

      it 'returns the degree review path' do
        expect(country_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_review_path
      end
    end

    context 'not reviewing' do
      let(:degree_params) { {} }

      it 'returns the do you have a degree path' do
        expect(country_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_university_degree_path
      end
    end
  end

  describe 'next_step' do
    context 'reviewing and unchanged country' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB').id,
          country: 'GB',
          uk_or_non_uk: 'uk',
        }
      end

      it 'returns review' do
        expect(country_form.next_step).to eq :review
      end
    end

    context 'not reviewing, uk' do
      let(:degree_params) do
        {
          country: 'GB',
          uk_or_non_uk: 'uk',
        }
      end

      it 'returns degree_level' do
        expect(country_form.next_step).to eq(:degree_level)
      end
    end

    context 'not reviewing, international, but country with compatible degrees' do
      let(:degree_params) do
        {
          country: 'NG',
          uk_or_non_uk: 'non_uk',
        }
      end

      it 'returns degree_level' do
        expect(country_form.next_step).to eq(:degree_level)
      end
    end

    context 'not reviewing, other international' do
      let(:degree_params) do
        {
          country: 'AU',
          uk_or_non_uk: 'non_uk',
        }
      end

      it 'returns type' do
        expect(country_form.next_step).to eq(:type)
      end
    end
  end
end

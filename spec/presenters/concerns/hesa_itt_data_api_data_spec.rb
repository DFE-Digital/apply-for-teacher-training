require 'rails_helper'

RSpec.describe HesaIttDataAPIData do
  subject(:presenter) { HesaITTDataClass.new(application_choice) }

  let(:hesa_itt_data_class) do
    Class.new do
      include HesaIttDataAPIData

      attr_accessor :application_choice, :application_form

      def initialize(application_choice)
        @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
        @application_form = application_choice.application_form
      end
    end
  end

  before do
    stub_const('HesaITTDataClass', hesa_itt_data_class)
  end

  describe '#hesa_itt_data' do
    let(:disabilities) { %w[Deaf] }
    let(:hesa_disabilities) { %w[57] }
    let(:hesa_ethnicity) { '10' }
    let(:hesa_sex) { '1' }
    let(:ethnic_group) { 'White' }
    let(:ethnic_background) { 'Irish' }
    let(:equality_and_diversity) do
      {
        ethnic_group:,
        ethnic_background:,
        disabilities:,
        hesa_disabilities:,
        hesa_ethnicity:,
        hesa_sex:,
      }
    end
    let(:recruitment_cycle_year) { 2022 }
    let(:application_form) { create(:application_form, :minimum_info, equality_and_diversity:, recruitment_cycle_year:) }
    let(:application_choice) { create(:application_choice, :accepted, application_form:) }

    context 'when an application choice has had an accepted offer' do
      it 'returns the hesa_itt_data attribute of an application' do
        expect(presenter.hesa_itt_data).to eq({
          disability: equality_and_diversity[:hesa_disabilities],
          ethnicity: equality_and_diversity[:hesa_ethnicity],
          sex: equality_and_diversity[:hesa_sex],
          other_disability_details: nil,
          other_ethnicity_details: nil,
        })
      end
    end

    context 'when the application choice has other disabilities' do
      let(:disabilities) { ['Deaf', 'A very specific thing'] }
      let(:hesa_disabilities) { %w[57 96] }

      it 'returns the other disability in the other_disability_details field' do
        expect(presenter.hesa_itt_data).to eq({
          disability: equality_and_diversity[:hesa_disabilities],
          ethnicity: equality_and_diversity[:hesa_ethnicity],
          sex: equality_and_diversity[:hesa_sex],
          other_disability_details: 'A very specific thing',
          other_ethnicity_details: nil,
        })
      end
    end

    context 'when the application choice has no disabilities or ethnicities' do
      let(:equality_and_diversity) { {} }

      it 'returns no the disability or ethnicity details' do
        expect(presenter.hesa_itt_data).to eq({
          disability: equality_and_diversity[:hesa_disabilities],
          ethnicity: equality_and_diversity[:hesa_ethnicity],
          sex: equality_and_diversity[:hesa_sex],
          other_disability_details: nil,
          other_ethnicity_details: nil,
        })
      end
    end

    context 'when the application choice has other freetext ethnicity' do
      let(:ethnic_group) { 'White' }
      let(:ethnic_background) { 'Custom ethnic background' }
      let(:hesa_ethnicity) { '10' }

      it 'returns the other ethnicity in the other_ethnicity_details field' do
        expect(presenter.hesa_itt_data).to eq({
          disability: equality_and_diversity[:hesa_disabilities],
          ethnicity: equality_and_diversity[:hesa_ethnicity],
          sex: equality_and_diversity[:hesa_sex],
          other_disability_details: nil,
          other_ethnicity_details: 'Custom ethnic background',
        })
      end
    end

    context 'when the application choice has other non-freetext ethnicity' do
      let(:ethnic_group) { 'Another ethnic group' }
      let(:ethnic_background) { 'Another ethnic background' }
      let(:hesa_ethnicity) { '80' }

      it 'does not return the other ethnicity in the other_ethnicity_details field' do
        expect(presenter.hesa_itt_data).to eq({
          disability: equality_and_diversity[:hesa_disabilities],
          ethnicity: equality_and_diversity[:hesa_ethnicity],
          sex: equality_and_diversity[:hesa_sex],
          other_disability_details: nil,
          other_ethnicity_details: nil,
        })
      end
    end

    context 'when the application choice has set prefer not to say as the ethnic background' do
      let(:ethnic_group) { 'Another ethnic group' }
      let(:ethnic_background) { 'Prefer not to say' }
      let(:hesa_ethnicity) { '98' }

      it 'does not return the other ethnicity in the other_ethnicity_details field' do
        expect(presenter.hesa_itt_data).to eq({
          disability: equality_and_diversity[:hesa_disabilities],
          ethnicity: equality_and_diversity[:hesa_ethnicity],
          sex: equality_and_diversity[:hesa_sex],
          other_disability_details: nil,
          other_ethnicity_details: nil,
        })
      end
    end

    context 'when an application choice has not had an accepted offer' do
      let(:application_form) { create(:application_form, :minimum_info, :with_equality_and_diversity_data) }
      let(:application_choice) { create(:application_choice, :offered, application_form:) }

      it 'the hesa_itt_data attribute of an application is nil' do
        expect(presenter.hesa_itt_data).to be_nil
      end
    end

    context 'when the application is from the 2022 recruitment cycle' do
      let(:recruitment_cycle_year) { 2022 }

      let(:hesa_disabilities) { %w[57] } # Deafness
      let(:hesa_ethnicity) { '10' } # White
      let(:hesa_sex) { '1' } # Male

      it 'returns the 2022 HESA codes' do
        expect(presenter.hesa_itt_data).to include(
          disability: %w[57],
          sex: '1',
          ethnicity: '10',
        )
      end
    end

    context 'when the application is from the 2023 recruitment cycle' do
      let(:recruitment_cycle_year) { 2023 }

      let(:hesa_disabilities) { %w[57] } # Deafness
      let(:hesa_ethnicity) { '166' } # White/Irish
      let(:hesa_sex) { '11' } # Male

      it 'returns nil instead of the HESA codes' do
        expect(presenter.hesa_itt_data).to include(
          disability: [],
          sex: nil,
          ethnicity: nil,
        )
      end
    end
  end
end

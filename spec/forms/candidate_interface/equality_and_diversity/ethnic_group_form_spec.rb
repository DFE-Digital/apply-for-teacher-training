require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::EthnicGroupForm, type: :model do
  describe '.build_from_application' do
    context 'when an application form has an ethnic group' do
      it 'creates a new ethnic group form with ethnic group of the application' do
        application_form = build_stubbed(:application_form, equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British' })

        form = described_class.build_from_application(application_form)

        expect(form.ethnic_group).to eq('Asian or Asian British')
      end
    end

    it 'returns nil if equality and diversity is nil' do
      application_form = build_stubbed(:application_form, equality_and_diversity: nil)

      form = described_class.build_from_application(application_form)

      expect(form.ethnic_group).to eq(nil)
    end

    it 'returns nil if ethnic group field is missing in equality and diversity' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'sex' => 'male' })

      form = described_class.build_from_application(application_form)

      expect(form.ethnic_group).to eq(nil)
    end
  end

  describe '#save' do
    let(:application_form) { build(:application_form) }

    context 'when ethnic group is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when ethnic group has a value' do
      it 'returns true' do
        form = described_class.new(ethnic_group: 'Prefer not to say')

        expect(form.save(application_form)).to be(true)
      end

      it 'updates the equality and diversity information on the application form' do
        form = described_class.new(ethnic_group: 'White')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq('ethnic_group' => 'White')
      end

      it 'updates the existing record of equality and diversity information' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male' })
        form = described_class.new(ethnic_group: 'Black, African, Black British or Caribbean')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male', 'ethnic_group' => 'Black, African, Black British or Caribbean',
        )
      end

      it 'resets the ethnic background and hesa code of equality and diversity information if ethnic group is "Prefer not to say"' do
        application_form = build(
          :application_form,
          equality_and_diversity: {
            'sex' => 'male',
            'ethnic_group' => 'Another ethnic group',
            'ethnic_background' => 'Arab',
            'hesa_ethnicity' => '50',
          },
        )
        form = described_class.new(ethnic_group: 'Prefer not to say')

        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male',
          'ethnic_group' => 'Prefer not to say',
          'ethnic_background' => nil,
          'hesa_ethnicity' => nil,
        )
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ethnic_group) }
  end
end

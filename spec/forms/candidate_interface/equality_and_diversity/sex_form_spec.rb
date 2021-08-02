require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::SexForm, type: :model do
  describe '#build_from_application' do
    it 'creates an object based on the application form' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'sex' => 'male' })
      form = described_class.build_from_application(application_form)

      expect(form.sex).to eq('male')
    end

    it 'returns nil if equality and diversity is nil' do
      application_form = build_stubbed(:application_form, equality_and_diversity: nil)
      form = described_class.build_from_application(application_form)

      expect(form.sex).to eq(nil)
    end
  end

  describe '#save' do
    let(:application_form) { build(:application_form) }

    context 'when sex is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when sex has a value' do
      it 'returns true' do
        form = described_class.new(sex: 'male')

        expect(form.save(application_form)).to be(true)
      end

      it 'updates the equality and diversity information on the application form' do
        form = described_class.new(sex: 'male')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq('sex' => 'male', 'hesa_sex' => '1')
      end

      it 'updates the existing record of equality and diversity information' do
        application_form = build(:application_form, equality_and_diversity: { 'disabilities' => [] })
        form = described_class.new(sex: 'female')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'female', 'hesa_sex' => '2', 'disabilities' => [],
        )
      end
    end

    context "sex is 'intersex'" do
      it 'updates equality and diversity information with the correct HESA code' do
        form = described_class.new(sex: 'intersex')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq('sex' => 'intersex', 'hesa_sex' => '3')
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:sex) }
  end
end

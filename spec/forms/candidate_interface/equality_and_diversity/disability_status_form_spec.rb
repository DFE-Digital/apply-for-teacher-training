require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::DisabilityStatusForm, type: :model do
  describe '.build_from_application' do
    context 'when an application form disabilities set to: Prefer not to say' do
      it 'creates an new disability status form with disability status set to Prefer not to say' do
        application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => ['Prefer not to say'] })
        form = described_class.build_from_application(application_form)

        expect(form.disability_status).to eq('Prefer not to say')
      end
    end

    context 'when an application form has no disabilities' do
      it 'creates an new disability status form with disability status set to no' do
        application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => [] })
        form = described_class.build_from_application(application_form)

        expect(form.disability_status).to eq('no')
      end
    end

    context 'when an application form has disabilities' do
      it 'creates an new disability status form with disability status set to yes' do
        application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => %w[stuff] })
        form = described_class.build_from_application(application_form)

        expect(form.disability_status).to eq('yes')
      end
    end

    it 'returns nil if equality and diversity is nil' do
      application_form = build_stubbed(:application_form, equality_and_diversity: nil)
      form = described_class.build_from_application(application_form)

      expect(form.disability_status).to be_nil
    end

    it 'returns nil if disabilities field is missing in equality and diversity' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'sex' => 'male' })
      form = described_class.build_from_application(application_form)

      expect(form.disability_status).to be_nil
    end
  end

  describe '#save' do
    let(:application_form) { build(:application_form) }

    context 'when disabilty status is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when disability status has a value' do
      it 'returns true' do
        form = described_class.new(disability_status: 'yes')

        expect(form.save(application_form)).to be(true)
      end

      it 'updates the equality and diversity information on the application form' do
        form = described_class.new(disability_status: 'no')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => [],
          'hesa_disabilities' => %w[95],
        )
      end

      it 'amends the equality and diversity information on the application form' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male' })
        form = described_class.new(disability_status: 'no')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male',
          'disabilities' => [],
          'hesa_disabilities' => %w[95],
        )
      end

      it 'updates the existing record of equality and diversity information' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male' })
        form = described_class.new(disability_status: 'yes')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male',
          'disabilities' => [],
          'hesa_disabilities' => [],
        )
      end

      it 'updates the existing disabilities of equality and diversity information' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male', 'disabilities' => %w[Blind] })
        form = described_class.new(disability_status: 'yes')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male',
          'disabilities' => %w[Blind],
        )
      end

      it 'resets the disabilities of equality and diversity information if disability status is no' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male', 'disabilities' => %w[Blind] })
        form = described_class.new(disability_status: 'no')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male',
          'disabilities' => [],
          'hesa_disabilities' => %w[95],
        )
      end

      it 'resets the disabilities of equality and diversity information if disability status is Prefer not to say' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male', 'disabilities' => %w[Blind], 'hesa_disabilities' => %w[58] })
        form = described_class.new(disability_status: 'Prefer not to say')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male',
          'disabilities' => ['Prefer not to say'],
          'hesa_disabilities' => [],
        )
      end

      it 'resets the disabilities of equality and diversity information if disability status is yes' do
        application_form = build(:application_form, equality_and_diversity: { 'sex' => 'male', 'disabilities' => ['Prefer not to say'] })
        form = described_class.new(disability_status: 'yes')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male',
          'disabilities' => [],
          'hesa_disabilities' => [],
        )
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:disability_status) }
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::DisabilitiesForm, type: :model do
  let(:old_cycle_disabilities) do
    %w[Blind Deaf]
  end
  let(:disabilities) do
    [
      I18n.t('equality_and_diversity.disabilities.blind.label'),
      I18n.t('equality_and_diversity.disabilities.deaf.label'),
    ]
  end
  let(:disabilities_with_other) do
    [
      disabilities,
      described_class::OTHER,
    ].flatten
  end
  let(:no_know_disability) do
    I18n.t('equality_and_diversity.disabilities.no.label')
  end
  let(:opt_out) do
    I18n.t('equality_and_diversity.disabilities.opt_out.label')
  end

  describe '.build_from_application' do
    it 'creates an object based on old application form' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => old_cycle_disabilities })
      form = described_class.build_from_application(application_form)

      expect(form.disabilities).to eq(disabilities)
    end

    it 'creates an object based on the application form' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => disabilities })
      form = described_class.build_from_application(application_form)

      expect(form.disabilities).to eq(disabilities)
    end

    it 'creates an object with other disability based on the application form' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => [disabilities, 'Other disability'].flatten })
      form = described_class.build_from_application(application_form)

      expect(form.disabilities).to eq(disabilities_with_other)
      expect(form.other_disability).to eq('Other disability')
    end

    it 'creates an object with no know disability based on the application form' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => [no_know_disability] })
      form = described_class.build_from_application(application_form)

      expect(form.disabilities).to eq([no_know_disability])
    end

    it 'creates an object with prefer not to say based on the application form' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => [opt_out] })
      form = described_class.build_from_application(application_form)

      expect(form.disabilities).to eq([opt_out])
    end

    it 'allows other disability to be undisclosed' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => disabilities_with_other })
      form = described_class.build_from_application(application_form)

      expect(form.disabilities).to eq(disabilities_with_other)
      expect(form.other_disability).to be_nil
    end

    it 'returns nil if equality and diversity is nil' do
      application_form = build_stubbed(:application_form, equality_and_diversity: nil)
      form = described_class.build_from_application(application_form)

      expect(form.disabilities).to be_nil
    end
  end

  describe '#save' do
    let(:application_form) { create(:application_form) }

    context 'when disabilities field is blank' do
      it 'returns false' do
        form = described_class.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when disabilities field has a value' do
      it 'returns true' do
        form = described_class.new(disabilities: disabilities)

        expect(form.save(application_form)).to be(true)
      end

      it 'saves no know disability' do
        disabilities = [no_know_disability]
        form = described_class.new(disabilities: disabilities)
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => disabilities,
          'hesa_disabilities' => %w[95],
        )
      end

      it 'saves prefer not to say' do
        disabilities = [I18n.t('equality_and_diversity.disabilities.opt_out.label')]
        form = described_class.new(disabilities: disabilities)
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => disabilities,
          'hesa_disabilities' => %w[98],
        )
      end

      it 'updates the equality and diversity information on the application form' do
        form = described_class.new(disabilities: disabilities_with_other, other_disability: 'Other disability')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => [disabilities, 'Other disability'].flatten,
          'hesa_disabilities' => %w[58 57 96],
        )
      end

      it 'allows other_disability field to be optional' do
        form = described_class.new(
          disabilities: disabilities_with_other,
          other_disability: '',
        )
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'disabilities' => disabilities_with_other,
          'hesa_disabilities' => %w[58 57 96],
        )
      end

      it 'updates the existing record of equality and diversity information' do
        application_form = create(:application_form, equality_and_diversity: { 'sex' => 'male' })
        form = described_class.new(
          disabilities: [disabilities, 'Other disability'].flatten,
        )
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male', 'hesa_disabilities' => %w[58 57 96], 'disabilities' => [disabilities, 'Other disability'].flatten,
        )
      end

      it 'does not update disabilities with other disability if Other is not selected' do
        application_form = create(:application_form, equality_and_diversity: { 'sex' => 'male' })
        form = described_class.new(disabilities: disabilities, other_disability: 'Other disability')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male', 'hesa_disabilities' => %w[58 57], 'disabilities' => disabilities,
        )
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:disabilities) }
  end
end

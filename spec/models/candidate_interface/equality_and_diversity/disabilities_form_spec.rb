require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::DisabilitiesForm, type: :model do
  describe '.build_from_application' do
    it 'creates an object based on the application form' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => %w[Blind Deaf] })
      form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.build_from_application(application_form)

      expect(form.disabilities).to eq(%w[Blind Deaf])
    end

    it 'creates an object with other disability based on the application form' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => ['Blind', 'Deaf', 'Other disability'] })
      form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.build_from_application(application_form)

      expect(form.disabilities).to eq(%w[Blind Deaf Other])
      expect(form.other_disability).to eq('Other disability')
    end

    it 'allows other disability to be undisclosed' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'disabilities' => %w[Blind Deaf Other] })
      form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.build_from_application(application_form)

      expect(form.disabilities).to eq(%w[Blind Deaf Other])
      expect(form.other_disability).to eq(nil)
    end

    it 'returns nil if equality and diversity is nil' do
      application_form = build_stubbed(:application_form, equality_and_diversity: nil)
      form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.build_from_application(application_form)

      expect(form.disabilities).to eq(nil)
    end
  end

  describe '#save' do
    let(:application_form) { create(:application_form) }

    context 'when disabilities field is blank' do
      it 'returns false' do
        form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when disabilities field has a value' do
      it 'returns true' do
        form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.new(disabilities: %w[Blind])

        expect(form.save(application_form)).to be(true)
      end

      it 'updates the equality and diversity information on the application form' do
        form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.new(disabilities: %w[Blind Other], other_disability: 'Other disability')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq('disabilities' => ['Blind', 'Other disability'])
      end

      it 'allows other_disability field to be optional' do
        form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.new(disabilities: %w[Blind Other], other_disability: '')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq('disabilities' => %w[Blind Other])
      end

      it 'updates the existing record of equality and diversity information' do
        application_form = create(:application_form, equality_and_diversity: { 'sex' => 'male' })
        form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.new(disabilities: %w[Blind])
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male', 'disabilities' => %w[Blind],
        )
      end

      it 'does not update disabilities with other disability if Other is not selected' do
        application_form = create(:application_form, equality_and_diversity: { 'sex' => 'male' })
        form = CandidateInterface::EqualityAndDiversity::DisabilitiesForm.new(disabilities: %w[Blind], other_disability: 'Other disability')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq(
          'sex' => 'male', 'disabilities' => %w[Blind],
        )
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:disabilities) }
  end
end

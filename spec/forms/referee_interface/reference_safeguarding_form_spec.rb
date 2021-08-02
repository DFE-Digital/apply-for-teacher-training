require 'rails_helper'

RSpec.describe RefereeInterface::ReferenceSafeguardingForm, type: :model do
  describe '.build_from_application' do
    it 'creates an object based on the application reference' do
      reference = build_stubbed(:reference, safeguarding_concerns: 'Very unreliable')
      form = described_class.build_from_reference(reference: reference)

      expect(form.safeguarding_concerns).to eq('Very unreliable')
    end

    context 'when safeguarding concern is blank' do
      it 'sets the any_safeguarding_concerns attribute to no' do
        reference = build_stubbed(:reference, safeguarding_concerns: '')
        form = described_class.build_from_reference(reference: reference)

        expect(form.any_safeguarding_concerns).to eq('no')
      end
    end

    context 'when safeguarding concern has a value' do
      it 'sets the any_safeguarding_concerns attribute to yes' do
        reference = build_stubbed(:reference, safeguarding_concerns: 'Very unreliable')
        form = described_class.build_from_reference(reference: reference)

        expect(form.any_safeguarding_concerns).to eq('yes')
      end
    end

    context 'when safeguarding concern is nil' do
      it 'sets the any_safeguarding_concerns attribute to nil' do
        reference = build_stubbed(:reference, safeguarding_concerns: nil)
        form = described_class.build_from_reference(reference: reference)

        expect(form.any_safeguarding_concerns).to eq(nil)
      end
    end
  end

  describe '#save' do
    let(:application_reference) { create(:reference) }

    context 'when any_safeguarding_concerns is blank' do
      it 'return false' do
        form = described_class.new

        expect(form.save(application_reference)).to be(false)
      end
    end

    context 'when any_safeguarding_concerns has value "no"' do
      it 'updates the safeguarding_concerns' do
        form = described_class.new(any_safeguarding_concerns: 'no')
        form.save(application_reference)

        expect(application_reference.safeguarding_concerns).to eq('')
      end
    end

    context 'when any_safeguarding_concerns has value "yes"' do
      it 'updates the safeguarding_concerns' do
        form = described_class.new(any_safeguarding_concerns: 'yes', safeguarding_concerns: 'rude')
        form.save(application_reference)

        expect(application_reference.safeguarding_concerns).to eq('rude')
      end
    end
  end

  describe 'validations' do
    it 'validate presence of any_safeguarding_concerns' do
      form = described_class.new(candidate: 'Donald Trump')
      expected_error_message = 'Select if you know of any reason why Donald Trump should not work with children'

      form.validate

      expect(form.errors.full_messages_for(:any_safeguarding_concerns)).to eq(
        ["Any safeguarding concerns #{expected_error_message}"],
      )
    end

    context 'when other any_safeguarding_concerns is nil or has value "no"' do
      it 'does not validate presence of safeguarding_concerns' do
        any_safeguarding_concerns = [nil, 'no'].sample
        form = described_class.new(any_safeguarding_concerns: any_safeguarding_concerns)
        form.validate

        expect(form.errors.full_messages_for(:safeguarding_concerns)).to be_empty
      end
    end

    context 'when both any_safeguarding_concerns and safeguarding_concerns present' do
      it 'does not show error messages' do
        form = described_class.new(any_safeguarding_concerns: 'yes', safeguarding_concerns: 'rude')

        form.validate

        expect(form.errors.full_messages_for(:any_safeguarding_concerns)).to be_empty
        expect(form.errors.full_messages_for(:safeguarding_concerns)).to be_empty
      end
    end
  end
end

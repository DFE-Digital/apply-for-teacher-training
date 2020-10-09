require 'rails_helper'

RSpec.describe CandidateInterface::Reference::CandidateNameForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end

  describe '.build_from_reference' do
    it 'populates the form based from a reference' do
      application_reference = build_stubbed(
        :reference,
        application_form: build_stubbed(:application_form, first_name: 'Walter', last_name: 'White'),
      )
      form = described_class.build_from_reference(application_reference)

      expect(form.first_name).to eq('Walter')
      expect(form.last_name).to eq('White')
    end
  end

  describe '#save' do
    let(:application_reference) do
      create(
        :reference,
        application_form: create(:application_form, first_name: nil, last_name: nil),
      )
    end

    before do
      FeatureFlag.activate('decoupled_references')
    end

    context 'when first_name is blank' do
      it 'returns false' do
        form = described_class.new(last_name: 'White')

        expect(form.save(application_reference)).to be(false)
      end
    end

    context 'when first and last_name both have a value' do
      it 'updates the application form' do
        form = described_class.new(first_name: 'Walter', last_name: 'White')
        form.save(application_reference)

        expect(application_reference.application_form.first_name).to eq('Walter')
        expect(application_reference.application_form.last_name).to eq('White')
      end
    end
  end
end

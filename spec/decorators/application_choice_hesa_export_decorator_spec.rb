require 'rails_helper'

RSpec.describe ApplicationChoiceHesaExportDecorator do
  describe 'nationality' do
    let(:decorated_application_form) { described_class.new(application_choice) }
    let(:application_choice) { create(:application_choice, application_form: application_form) }

    context 'when dual nationality including British' do
      let(:application_form) { create(:application_form, first_nationality: 'Cypriot', second_nationality: 'British') }

      it 'returns GB' do
        expect(decorated_application_form.nationality).to eq('GB')
      end
    end

    context 'when dual nationality, not including British, but including non-UK EU country' do
      let(:application_form) { create(:application_form, first_nationality: 'Cypriot', second_nationality: 'American') }

      it 'returns the EU country code' do
        expect(decorated_application_form.nationality).to eq('CY')
      end
    end

    context 'when dual nationality and both are non-UK EU countries' do
      let(:application_form) { create(:application_form, first_nationality: 'Greek', second_nationality: 'Hungarian') }

      it 'returns the first EU country code' do
        expect(decorated_application_form.nationality).to eq('GR')
      end
    end

    context 'when dual nationality and both are neither is British or EU' do
      let(:application_form) { create(:application_form, first_nationality: 'Indian', second_nationality: 'American') }

      it 'returns the first occuring nationality' do
        expect(decorated_application_form.nationality).to eq('IN')
      end
    end
  end
end

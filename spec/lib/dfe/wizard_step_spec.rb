require 'rails_helper'

RSpec.describe DfE::WizardStep do
  describe '.model_name' do
    it 'returns the name demodulized' do
      expect(described_class.model_name).to eq('Wizard')
    end
  end

  describe '.formatted_name' do
    it 'returns the name without the step suffix' do
      expect(described_class.formatted_name).to eq('DfE::Wizard')
    end
  end

  describe '.route_name' do
    it 'returns the name as a route' do
      expect(described_class.route_name).to eq('dfe_wizard')
    end
  end

  describe '#step_name' do
    it 'returns the name of the step' do
      expect(described_class.new.step_name).to eq('Wizard')
    end
  end
end

require 'rails_helper'

RSpec.describe DfE::WizardStore do
  subject(:store) { described_class.new(wizard) }

  describe '#wizard' do
    let(:wizard) { DfE::Wizard.new(current_step: :foo) }

    it 'returns wizard' do
      expect(store.wizard).to eq(wizard)
    end
  end
end

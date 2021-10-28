require 'rails_helper'

RSpec.describe Wizard::PathHistory do
  let(:wizard) do
    Class.new do
      include Wizard
      include Wizard::PathHistory
    end
  end
  let(:attrs) { {} }
  let(:store) { instance_double(WizardStateStores::RedisStore, read: nil) }

  subject(:model) { WizardClass.new(store, attrs) }

  before do
    stub_const('WizardClass', wizard)
  end

  describe '#previous_step' do
    let(:wizard_path_history) { WizardPathHistory.new([:previous_step], step: :current_step) }

    context 'when there is a previous step' do
      it 'returns the previous step stored on the wizard_path_history' do
        allow(WizardPathHistory).to receive(:new).and_return(wizard_path_history)

        expect(model.previous_step).to eq(:previous_step)
      end
    end

    context 'when there is no previous step' do
      let(:wizard_path_history) { WizardPathHistory.new([]) }

      it 'returns the referer' do
        allow(WizardPathHistory).to receive(:new).and_return(wizard_path_history)

        expect(model.previous_step).to eq(:referer)
      end
    end
  end

  describe '#setup_path_history' do
    let(:attrs) { { current_step: :check } }

    it 'updates the wizard path history' do
      expect(model.wizard_path_history.path_history).to eq(%i[referer check])
    end
  end
end

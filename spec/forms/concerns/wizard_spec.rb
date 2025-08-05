require 'rails_helper'

RSpec.describe Wizard do
  let(:wizard) { Class.new { include Wizard } }
  let(:attrs) { {} }
  let(:store) { instance_double(WizardStateStores::RedisStore, read: nil) }

  subject(:model) { WizardClass.new(store, attrs) }

  before do
    stub_const('WizardClass', wizard)
  end

  describe 'attributes' do
    it 'has a set of predefined attributes' do
      expect(model).to respond_to(:current_step)
      expect(model).to respond_to(:action)
      expect(model).to respond_to(:referer)
      expect(model).to respond_to(:state_store)
    end
  end

  describe '#initialize_extra' do
    let(:wizard) do
      Class.new do
        include Wizard

        attr_accessor :checking_answers

        def initialize_extra(_attrs)
          @checking_answers = true if current_step.eql?(:check)
        end
      end
    end
    let(:attrs) { { current_step: :check } }

    it 'runs additional actions as part of the initializer' do
      expect(model.checking_answers).to be true
    end
  end

  describe '#sanitize_attrs' do
    let(:wizard) do
      Class.new do
        include Wizard

        attr_accessor :value1, :value2

        def sanitize_attrs(attrs)
          attrs[:value1] = :test if attrs[:value2].nil?
          attrs
        end
      end
    end
    let(:attrs) { { value1: 'some_value' } }

    it 'runs any required attribute sanitisation' do
      expect(model.value1).to eq(:test)
    end
  end

  describe '#clear_state!' do
    it 'deletes the state store' do
      allow(store).to receive(:delete)

      model.clear_state!

      expect(store).to have_received(:delete)
    end
  end

  describe '#save_state!' do
    let(:wizard) do
      Class.new do
        attr_accessor :value1, :value2
        include Wizard
      end
    end
    let(:attrs) { { value1: 'field1', value2: 'field2' } }

    it 'saves the state store' do
      allow(store).to receive(:write)

      model.save_state!

      expect(store).to have_received(:write).with(attrs.to_json)
    end
  end

  describe '#valid_for_current_step?' do
    let(:wizard) do
      Class.new do
        include Wizard

        validates :referer, presence: true, on: :step_1
        validates :action, presence: true, on: :step_2
      end
    end
    let(:attrs) { { current_step: :step_1 } }

    it 'checks the wizard validity for the current step' do
      expect(model.valid_for_current_step?).to be(false)

      expect(model.errors[:referer]).to contain_exactly("can't be blank")
      expect(model.errors[:action]).to be_empty
    end
  end
end

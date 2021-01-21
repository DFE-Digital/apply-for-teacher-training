require 'rails_helper'
RSpec.describe 'Wizard' do
  let(:test_wizard_form) do
    Class.new do
      include ActiveModel::Model
      include Wizard

      attr_accessor :name, :email, :phone_number

      validates :name, :email, presence: true
      validates :phone_number, presence: true, on: :new
    end
  end

  let(:described_class) { TestWizardForm }
  let(:store) { instance_double(WizardStateStores::RedisStore, read: nil, delete: nil) }
  let(:wizard) { described_class.new(store, name: 'Jean', email: 'jean@dfe.com') }

  before do
    stub_const('TestWizardForm', test_wizard_form)
  end

  describe '#initialize' do
    let(:params) { { name: 'Fiona' } }

    it 'merges any attributes with ones stored in the data store' do
      allow(store).to receive(:read).and_return({ name: 'Jane', email: 'fiona@dfe.co.uk' }.to_json)

      wizard = described_class.new(store, params)

      expect(wizard.name).to eq('Fiona')
      expect(wizard.email).to eq('fiona@dfe.co.uk')
    end

    context 'when parameter sanitisation is required' do
      let(:test_wizard_form) do
        Class.new do
          include ActiveModel::Model
          include Wizard

          attr_accessor :name

          def sanitize_attributes!(params)
            params.delete(:name)
          end
        end
      end

      it 'must be specified in the inherited class' do
        wizard = described_class.new(store, params)

        expect(wizard.name).to be_nil
      end
    end
  end

  describe '#next_step' do
    it 'is a placeholder and returns nil' do
      expect(wizard.next_step).to eq(nil)
    end
  end

  describe '#previous_step' do
    it 'is a placeholder and returns nil' do
      expect(wizard.previous_step).to eq(nil)
    end
  end

  describe '#valid?' do
    context 'when failing validations are related to a specific step' do
      context 'when on another step and validating' do
        it 'returns true' do
          wizard.current_step = :check

          expect(wizard.valid?).to be(true)
        end
      end

      context 'when on the associated step and validating' do
        it 'returns false' do
          wizard.current_step = :new

          expect(wizard.valid?).to be(false)
          expect(wizard.errors[:phone_number]).to include('can\'t be blank')
        end
      end
    end

    context 'when no current step is specified' do
      it 'returns true' do
        expect(wizard.valid?).to be(true)
      end
    end
  end

  describe '#save_state!' do
    it 'stores the the model params in json format excluding helper params' do
      included_params_to_json = { name: 'Jean', email: 'jean@dfe.com' }.to_json
      allow(store).to receive(:write)

      wizard.save_state!

      expect(store).to have_received(:write).with(included_params_to_json)
    end
  end

  describe '#clear_state' do
    it 'calls the data store\'s delete method' do
      wizard.clear_state!

      expect(store).to have_received(:delete)
    end
  end
end

require 'rails_helper'

RSpec.describe ProviderInterface::ReconfirmDeferredOfferWizard do
  def state_store_for(state)
    WizardStateStores::SessionStore.new(session: { 'key' => state.to_json }, key: 'key')
  end

  let(:application_choice) { create(:application_choice, :previous_year_but_still_available, :offer_deferred) }

  describe 'validations' do
    context ':current_step' do
      let(:state_store) { state_store_for(application_choice_id: application_choice.id) }

      it 'must be provided' do
        wizard = described_class.new(state_store, current_step: nil)
        expect(wizard).not_to be_valid
      end

      it 'must be a valid step' do
        wizard = described_class.new(state_store, current_step: 'unknown')
        expect(wizard).not_to be_valid

        wizard = described_class.new(state_store, current_step: 'new')
        expect(wizard).to be_valid
      end
    end

    context 'step: \'new\'' do
      let(:wrong_status) { create(:application_choice, :previous_year, :recruited) }
      let(:wrong_year) { create(:application_choice, :offer_deferred) }

      def wizard_for(state_store)
        described_class.new(state_store, current_step: 'new')
      end

      it 'crashes without an ApplicationChoice' do
        this_state = state_store_for(application_choice_id: nil)
        expect { wizard_for(this_state).valid? }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'is not valid if the ApplicationChoice status is wrong' do
        this_state = state_store_for(application_choice_id: wrong_status.id)
        expect(wizard_for(this_state)).not_to be_valid
      end

      it 'is not valid if the deferred offer is from the current year' do
        this_state = state_store_for(application_choice_id: wrong_year.id)
        expect(wizard_for(this_state)).not_to be_valid
      end
    end

    context 'step: \'conditions\'' do
      def wizard_for(state_store)
        described_class.new(state_store, current_step: 'conditions')
      end

      it 'is not valid if original offer was for an option not currently available' do
        this_state = state_store_for(application_choice_id: create(:application_choice, :previous_year, :offer_deferred).id)
        expect(wizard_for(this_state)).not_to be_valid
      end

      it 'requires confirmed status of conditions' do
        this_state = state_store_for(application_choice_id: application_choice.id)
        expect(wizard_for(this_state)).not_to be_valid_for_current_step

        this_state = state_store_for(
          application_choice_id: application_choice.id,
          conditions_status: 'met',
        )
        expect(wizard_for(this_state)).to be_valid
      end
    end

    context 'step: \'check\'' do
      def wizard_for(state_store)
        described_class.new(state_store, current_step: 'check')
      end

      it 'requires a course option id' do
        this_state = state_store_for(
          application_choice_id: application_choice.id,
          conditions_status: 'met',
        )
        expect(wizard_for(this_state)).not_to be_valid_for_current_step

        this_state = state_store_for(
          application_choice_id: application_choice.id,
          conditions_status: 'met',
          course_option_id: 99,
        )
        expect(wizard_for(this_state)).to be_valid
      end
    end
  end

  describe '#modified_application_choice' do
    def modified_application_choice_for(state_store)
      wizard = described_class.new(state_store, current_step: 'conditions')
      wizard.valid?
      wizard.modified_application_choice
    end

    it 'returns a modified copy of the application choice' do
      state_store = state_store_for(application_choice_id: application_choice.id)

      expect(modified_application_choice_for(state_store).changed?).to be true
    end

    it 'returns the original choice status if conditions_status is not known' do
      state_store = state_store_for(application_choice_id: application_choice.id)
      expect(modified_application_choice_for(state_store).status).to eq('pending_conditions')

      recruited_choice = create(:application_choice, :offer_deferred_after_recruitment)
      state_store = state_store_for(application_choice_id: recruited_choice.id)
      expect(modified_application_choice_for(state_store).status).to eq('recruited')
    end

    it 'changes the status of the application choice and conditions to recruited if the condition status is set to met' do
      state_store = state_store_for(
        application_choice_id: application_choice.id,
        conditions_status: 'met',
      )
      application_choice = modified_application_choice_for(state_store)

      expect(application_choice.offer.conditions.map(&:status)).to eq(%w[met])
      expect(modified_application_choice_for(state_store).status).to eq('recruited')
    end

    it 'changes the status of the application choice and conditions to pending if the condition status is set to not met' do
      recruited_choice = create(:application_choice, :offer_deferred_after_recruitment)
      state_store = state_store_for(
        application_choice_id: recruited_choice.id,
        conditions_status: 'not met',
      )
      application_choice = modified_application_choice_for(state_store)

      expect(application_choice.offer.conditions.map(&:status)).to eq(%w[pending])
      expect(modified_application_choice_for(state_store).status).to eq('pending_conditions')
    end
  end

  describe '#conditions_met?' do
    def conditions_met?(conditions_status)
      state_store = state_store_for(
        application_choice_id: application_choice.id,
        conditions_status:,
      )
      wizard = described_class.new(state_store, current_step: 'conditions')
      wizard.valid?
      wizard.conditions_met?
    end

    it 'is falsy if conditions_status is unknown' do
      expect(conditions_met?(nil)).to be_falsey
    end

    it 'is false if conditions_status is \'not met\'' do
      expect(conditions_met?('not met')).to be_falsey
    end

    it 'is true if conditions_status is \'met\'' do
      expect(conditions_met?('met')).to be_truthy
    end
  end

  describe '#next_step' do
    let(:state_store) { state_store_for(application_choice_id: application_choice.id) }

    it 'returns \'new\' step if no other information is present' do
      wizard = described_class.new(state_store, current_step: nil)
      expect(wizard.next_step).to eq(:new)
    end

    it 'returns \'conditions\' step if already on the new step' do
      wizard = described_class.new(state_store, current_step: 'new')
      expect(wizard.next_step).to eq(:conditions)
    end

    it 'returns \'check\' step on the conditions step' do
      wizard = described_class.new(state_store, current_step: 'conditions')
      expect(wizard.next_step).to eq(:check)
    end

    it 'returns nil on the check step' do
      wizard = described_class.new(state_store, current_step: 'check')
      expect(wizard.next_step).to be_nil
    end
  end

  describe '#previous_step' do
    let(:state_store) { state_store_for(application_choice_id: application_choice.id) }

    it 'is nil if on \'new\' step' do
      wizard = described_class.new(state_store, current_step: 'new')
      expect(wizard.previous_step).to be_nil
    end

    it 'returns \'new\' step if on the conditions step' do
      wizard = described_class.new(state_store, current_step: 'conditions')
      expect(wizard.previous_step).to eq(:new)
    end

    it 'returns \'conditions\' step if on the check step' do
      wizard = described_class.new(state_store, current_step: 'check')
      expect(wizard.previous_step).to eq(:conditions)
    end
  end
end

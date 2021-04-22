require 'rails_helper'

RSpec.describe ProviderInterface::ReconfirmDeferredOfferWizard do
  def state_store_for(state)
    WizardStateStores::SessionStore.new(session: { 'key' => state.to_json }, key: 'key')
  end

  let(:application_choice) { create(:application_choice, :previous_year_but_still_available, :with_deferred_offer) }

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

        wizard = described_class.new(state_store, current_step: 'start')
        expect(wizard).to be_valid
      end
    end

    context 'step: \'start\'' do
      let(:wrong_status) { create(:application_choice, :previous_year, :with_recruited) }
      let(:wrong_year) { create(:application_choice, :with_deferred_offer) }

      def wizard_for(state_store)
        described_class.new(state_store, current_step: 'start')
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

      let(:no_such_option_now) { create(:application_choice, :previous_year, :with_deferred_offer) }

      it 'is not valid if original offer was for an option not currently available' do
        this_state = state_store_for(application_choice_id: no_such_option_now.id)
        expect(wizard_for(this_state)).not_to be_valid
      end

      it 'is not valid if equivalent option exists but is not open on Apply' do
        application_choice.current_course.in_next_cycle.update(open_on_apply: false)
        this_state = state_store_for(application_choice_id: application_choice.id)
        expect(wizard_for(this_state)).not_to be_valid
      end

      it 'requires confirmed status of conditions' do
        this_state = state_store_for(application_choice_id: application_choice.id)
        expect(wizard_for(this_state)).not_to be_valid

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
        expect(wizard_for(this_state)).not_to be_valid

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

    it 'returns an unpersisted copy of the application choice' do
      state_store = state_store_for(application_choice_id: application_choice.id)
      expect(modified_application_choice_for(state_store)).not_to be_persisted
    end

    it 'returns the original choice status if conditions_status is not known' do
      state_store = state_store_for(application_choice_id: application_choice.id)
      expect(modified_application_choice_for(state_store).status).to eq('pending_conditions')

      recruited_choice = create(:application_choice, :with_deferred_offer_previously_recruited)
      state_store = state_store_for(application_choice_id: recruited_choice.id)
      expect(modified_application_choice_for(state_store).status).to eq('recruited')
    end

    it 'returns a new status according to conditions_status if this is known' do
      state_store = state_store_for(
        application_choice_id: application_choice.id,
        conditions_status: 'met',
      )
      expect(modified_application_choice_for(state_store).status).to eq('recruited')

      recruited_choice = create(:application_choice, :with_deferred_offer_previously_recruited)
      state_store = state_store_for(
        application_choice_id: recruited_choice.id,
        conditions_status: 'not met',
      )
      expect(modified_application_choice_for(state_store).status).to eq('pending_conditions')
    end
  end

  describe '#conditions_met?' do
    def conditions_met?(conditions_status)
      state_store = state_store_for(
        application_choice_id: application_choice.id,
        conditions_status: conditions_status,
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

    it 'returns \'start\' step if no other information is present' do
      wizard = described_class.new(state_store, current_step: nil)
      expect(wizard.next_step).to eq(:start)
    end

    it 'returns \'conditions\' step if already on the start step' do
      wizard = described_class.new(state_store, current_step: 'start')
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

    it 'is nil if on \'start\' step' do
      wizard = described_class.new(state_store, current_step: 'start')
      expect(wizard.previous_step).to be_nil
    end

    it 'returns \'start\' step if on the conditions step' do
      wizard = described_class.new(state_store, current_step: 'conditions')
      expect(wizard.previous_step).to eq(:start)
    end

    it 'returns \'conditions\' step if on the check step' do
      wizard = described_class.new(state_store, current_step: 'check')
      expect(wizard.previous_step).to eq(:conditions)
    end
  end

  describe 'initializer' do
    it 'deserializes state' do
      state_store = state_store_for(application_choice_id: application_choice.id)
      wizard = described_class.new(state_store, current_step: 'start')
      expect(wizard.application_choice_id).to eq application_choice.id
    end
  end

  describe '#save_state!' do
    it 'serializes state to state store' do
      state_store = state_store_for(application_choice_id: application_choice.id)
      wizard = described_class.new(state_store)
      wizard.course_option_id = 99

      wizard.save_state!

      expect(JSON.parse(state_store.read).symbolize_keys).to eq({
        application_choice_id: application_choice.id,
        course_option_id: 99,
      })
    end
  end

  describe '#clear_state!' do
    it 'purges all state' do
      state_store = state_store_for(application_choice_id: application_choice.id)
      wizard = described_class.new(state_store)

      wizard.clear_state!

      expect(state_store.read).to be_nil
    end
  end
end

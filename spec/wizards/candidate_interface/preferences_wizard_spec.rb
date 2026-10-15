require 'rails_helper'

RSpec.describe CandidateInterface::PreferencesWizard, type: :model do
  let(:repository) do
    DfE::Wizard::Repository::InMemory.new
  end
  let(:state_store) { CandidateInterface::StateStores::PreferencesWizardStore.new(repository:) }

  describe 'delegations' do
    subject(:wizard) { described_class.new(state_store:) }

    it { is_expected.to delegate_method(:opt_in?).to(:state_store) }
    it { is_expected.to delegate_method(:opt_out?).to(:state_store) }
    it { is_expected.to delegate_method(:training_locations_anywhere?).to(:state_store) }
    it { is_expected.to delegate_method(:training_locations_specific?).to(:state_store) }
    it { is_expected.to delegate_method(:only_salaried_courses_and_anywhere?).to(:state_store) }
    it { is_expected.to delegate_method(:applied_only_to_salaried_courses?).to(:state_store) }
    it { is_expected.to delegate_method(:training_locations).to(:state_store) }
    it { is_expected.to delegate_method(:funding_type).to(:state_store) }
    it { is_expected.to delegate_method(:location_name).to(:state_store) }
    it { is_expected.to delegate_method(:location_preferences).to(:state_store) }
    it { is_expected.to delegate_method(:dynamic_location_preferences?).to(:state_store) }
    it { is_expected.to delegate_method(:any_notifications?).to(:state_store) }
    it { is_expected.to delegate_method(:preference).to(:state_store) }
  end

  describe 'steps' do
    subject(:wizard) do
      described_class.new(
        state_store:,
        current_step_params:,
      ).tap do |wizard|
        wizard.current_application = application_form
      end
    end

    let(:current_step_params) { { current_application_id: application_form.id } }
    let(:application_form) { create(:completed_application_form) }

    describe 'root_step' do
      it 'returns the :opt_in as the root step' do
        expect(wizard.root_step).to eq(:opt_in)
      end
    end

    describe 'next_steps' do
      it { is_expected.to have_next_step(:opt_out) }

      context 'when pool_status is opt_in' do
        before { allow(state_store).to receive(:opt_in?).and_return(true) }

        it { is_expected.to have_next_step(:training_locations) }
      end
    end

    describe 'branching from training_locations' do
      context 'when the candidate has applied only to salaried courses and selected to train anywhere' do
        before { allow(state_store).to receive(:only_salaried_courses_and_anywhere?).and_return(true) }

        it { is_expected.to branch_from(:training_locations).to(:funding_preference) }
      end

      context 'when the candidate has selected to train anywhere' do
        before do
          allow(state_store).to receive_messages(only_salaried_courses_and_anywhere?: false, training_locations_anywhere?: true)
        end

        it { is_expected.to branch_from(:training_locations).to(:publish) }
      end

      context 'when the candidate has selected to train in specific locations' do
        before do
          allow(state_store).to receive_messages(
            only_salaried_courses_and_anywhere?: false,
            training_locations_anywhere?: false,
            training_locations_specific?: true,
          )
        end

        it { is_expected.to branch_from(:training_locations).to(:location_preference_list) }
      end
    end

    describe 'branching from add_location_preference' do
      it { is_expected.to branch_from(:add_location_preference).to(:location_preference_list) }
    end

    describe 'branching from remove_location_preference' do
      it { is_expected.to branch_from(:remove_location_preference).to(:location_preference_list) }
    end

    describe 'branching from location_preference_list' do
      it { is_expected.to branch_from(:location_preference_list).to(:dynamic_location_preferences) }
    end

    describe 'branching from dynamic_location_preferences' do
      context 'when the candidate has only applied for salaried courses' do
        before { allow(state_store).to receive(:applied_only_to_salaried_courses?).and_return(true) }

        it { is_expected.to branch_from(:dynamic_location_preferences).to(:funding_preference) }
      end

      context 'when the candidate has not only applied for salaried courses' do
        before { allow(state_store).to receive(:applied_only_to_salaried_courses?).and_return(false) }

        it { is_expected.to branch_from(:dynamic_location_preferences).to(:publish) }
      end
    end

    describe 'branching from funding_preference' do
      it { is_expected.to branch_from(:funding_preference).to(:publish) }
    end

    describe 'branching from publish' do
      context 'when the application has notifications' do
        before { allow(state_store).to receive(:any_notifications?).and_return(true) }

        it { is_expected.to branch_from(:publish).to(:invites) }
      end

      context 'when the application has no notifications' do
        before { allow(state_store).to receive(:any_notifications?).and_return(false) }

        it { is_expected.to branch_from(:publish).to(:confirmation) }
      end
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::StateStores::PreferencesWizardStore, type: :model do
  subject(:state_store) { described_class.new(repository:) }

  let(:repository) do
    DfE::Wizard::Repository::InMemory.new
  end
  let(:wizard) do
    CandidateInterface::PreferencesWizard.new(
      current_step:,
      current_step_params:,
      state_store:,
    ).tap do |wizard|
      wizard.current_application = current_application
    end
  end
  let(:current_application) { create(:completed_application_form) }
  let(:candidate) { current_application.candidate }
  let(:current_step) { :opt_in }
  let(:current_step_params) { {} }

  before do
    wizard
    state_store.write(current_application_id: current_application.id)
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:candidate).to(:current_application) }
    it { is_expected.to delegate_method(:applied_only_to_salaried_courses?).to(:candidate) }
  end

  describe '#current_application' do
    it 'returns the current application' do
      expect(state_store.current_application).to eq(current_application)
    end
  end

  describe '#preference' do
    context 'when no published or duplicated preference exists' do
      it 'returns nil' do
        expect(state_store.preference).to be_nil
      end
    end

    context 'when the application form has a published preference' do
      let(:preference) { create(:candidate_preference, application_form: current_application) }

      before { preference }

      it 'returns the published preference' do
        expect(state_store.preference).to eq(preference)
      end
    end

    context 'when the application form has a duplicated preference' do
      let(:preference) { create(:candidate_preference, :duplicated, application_form: current_application) }

      before { preference }

      it 'returns the duplicated preference' do
        expect(state_store.preference).to eq(preference)
      end
    end
  end

  describe '#opt_in?' do
    context 'when the pool status is opt_in' do
      before { state_store.write(pool_status: 'opt_in') }

      it 'returns true' do
        expect(state_store.opt_in?).to be(true)
      end
    end

    context 'when the pool status is opt_out' do
      before { state_store.write(pool_status: 'opt_out') }

      it 'returns false' do
        expect(state_store.opt_in?).to be(false)
      end
    end
  end

  describe '#opt_out?' do
    context 'when the pool status is opt_in' do
      before { state_store.write(pool_status: 'opt_in') }

      it 'returns false' do
        expect(state_store.opt_out?).to be(false)
      end
    end

    context 'when the pool status is opt_out' do
      before { state_store.write(pool_status: 'opt_out') }

      it 'returns true' do
        expect(state_store.opt_out?).to be(true)
      end
    end
  end

  describe '#training_locations_anywhere?' do
    context 'when the training locations is anywhere' do
      before { state_store.write(training_locations: 'anywhere') }

      it 'returns true' do
        expect(state_store.training_locations_anywhere?).to be(true)
      end
    end

    context 'when the training locations not anywhere' do
      before { state_store.write(training_locations: 'specific') }

      it 'returns false' do
        expect(state_store.training_locations_anywhere?).to be(false)
      end
    end
  end

  describe '#training_locations_specific?' do
    context 'when the training locations is specific' do
      before { state_store.write(training_locations: 'specific') }

      it 'returns true' do
        expect(state_store.training_locations_specific?).to be(true)
      end
    end

    context 'when the training locations not specific' do
      before { state_store.write(training_locations: 'anywhere') }

      it 'returns false' do
        expect(state_store.training_locations_specific?).to be(false)
      end
    end
  end

  describe '#only_salaried_courses_and_anywhere?' do
    context 'when the candidate has applied to only salaried courses' do
      before do
        allow(candidate).to receive(:applied_only_to_salaried_courses?).and_return(true)
      end

      context 'when the candidate has selected to train anywhere' do
        before { state_store.write(training_locations: 'anywhere') }

        it 'returns true' do
          expect(state_store.only_salaried_courses_and_anywhere?).to be(true)
        end
      end

      context 'when the candidate has selected to train in a specific location' do
        before { state_store.write(training_locations: 'specific') }

        it 'returns false' do
          expect(state_store.only_salaried_courses_and_anywhere?).to be(false)
        end
      end
    end

    context 'when the candidate has not applied to only salaried courses' do
      before do
        allow(candidate).to receive(:applied_only_to_salaried_courses?).and_return(false)
      end

      it 'returns false' do
        expect(state_store.only_salaried_courses_and_anywhere?).to be(false)
      end
    end
  end

  describe '#location_preferences' do
    context 'when no locations preference have been set' do
      it 'returns an empty array' do
        expect(state_store.location_preferences).to eq([])
      end
    end

    context 'when locations preferences have been set' do
      let(:location_preference_list) do
        [{ uid: 'abc123', within: 10, location_name: 'Bristol' }]
      end

      before { state_store.write(location_preference_list:) }

      it 'returns an array of location attributes' do
        expect(state_store.location_preferences).to eq(location_preference_list)
      end
    end
  end

  describe '#dynamic_location_preferences?' do
    context 'when the dynamic_location_preferences is true' do
      before { state_store.write(dynamic_location_preferences: 'true') }

      it 'returns true' do
        expect(state_store.dynamic_location_preferences?).to be(true)
      end
    end

    context 'when the training locations not specific' do
      before { state_store.write(dynamic_location_preferences: 'false') }

      it 'returns false' do
        expect(state_store.dynamic_location_preferences?).to be(false)
      end
    end
  end

  describe '#any_notifications?' do
    context 'when the application form has notifications' do
      before do
        create(:notification, notified: current_application)
      end

      it 'returns true' do
        expect(state_store.any_notifications?).to be(true)
      end
    end

    context 'when the application form has no notifications' do
      it 'returns true' do
        expect(state_store.any_notifications?).to be(false)
      end
    end
  end
end

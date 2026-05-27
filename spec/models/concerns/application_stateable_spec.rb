require 'rails_helper'

RSpec.describe ApplicationStateable do
  describe 'delegations' do
    subject(:delegated_choice) { create(:application_choice) }

    it { is_expected.to delegate_method(:visible_to_provider?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:visible_to_provider).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:interviewable?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:interviewable).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:offered?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:offered).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:post_offered?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:post_offered).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:offer_accepted?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:offer_accepted).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:unsuccessful?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:unsuccessful).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:carry_over?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:carry_over).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:successful?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:successful).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:pending_provider_decision?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:pending_provider_decision).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:reapply?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:reapply).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:terminal?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:terminal).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:in_progress?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:in_progress).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:active_previous?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:active_previous).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:chase_referee?).to(:state).with_prefix('state') }
    it { is_expected.to delegate_method(:chase_referee).to(:state).with_prefix('state') }
  end

  describe '.state' do
    ApplicationChoice.statuses.symbolize_keys.each_key do |status|
      it "returns the Application State with the #{status} id" do
        choice = create(:application_choice, status: status)
        expect(choice.state).to eq(ApplicationStateChange::ApplicationState.find(status))
      end
    end
  end

  describe '.state_pending_provider_decision_or_inactive?' do
    %i[awaiting_provider_decision interviewing inactive].each do |status|
      it "returns true when the application choice status is #{status}" do
        choice = create(:application_choice, status: status)
        expect(choice.state_pending_provider_decision_or_inactive?).to be(true)
      end
    end

    %i[unsubmitted cancelled offer pending_conditions recruited rejected application_not_sent
       offer_withdrawn declined withdrawn conditions_not_met offer_deferred].each do |status|
      it "returns false when the application choice status is #{status}" do
        choice = create(:application_choice, status: status)
        expect(choice.state_pending_provider_decision_or_inactive?).to be(false)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ApplicationStateChange::ApplicationState do
  describe '.all' do
    it 'returns all application states with their attributes' do
      states = described_class.all

      expect(states.size).to eq(15)

      expect(states.map(&:id)).to contain_exactly(
        :withdrawn, :unsubmitted, :awaiting_provider_decision, :inactive,
        :interviewing, :rejected, :application_not_sent, :offer,
        :offer_withdrawn, :declined, :pending_conditions,
        :conditions_not_met, :recruited, :cancelled, :offer_deferred
      )

      expect(states).to all(be_a(described_class))
    end
  end

  describe '.find' do
    it 'returns the correct application state by id' do
      state = described_class.find(:withdrawn)

      expect(state.id).to eq(:withdrawn)
      expect(state).to be_a(described_class)
    end

    it 'returns nil form unknown ids' do
      state = described_class.find(:unknown)

      expect(state).to be_nil
    end
  end

  describe '.where' do
    it 'returns the correct application states by ids' do
      states = described_class.where(id: %i[withdrawn unsubmitted])

      expect(states.size).to eq(2)
      expect(states.map(&:id)).to contain_exactly(:withdrawn, :unsubmitted)
      expect(states).to all(be_a(described_class))
    end

    it 'returns an empty array for unknown ids' do
      states = described_class.where(id: [:unknown])

      expect(states).to be_empty
    end

    it 'returns the correct application states using attributes' do
      states = described_class.where(
        offered: true,
        post_offered: true,
        terminal: true,
      )

      expect(states.size).to eq(4)
      expect(states.map(&:id)).to contain_exactly(
        :offer_withdrawn, :declined, :conditions_not_met, :recruited
      )
    end
  end

  describe 'scopes' do
    describe '.not_visible_to_provider' do
      subject(:scope_method) { described_class.not_visible_to_provider }

      it 'returns only states that are not visible to provider' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :unsubmitted,
          :application_not_sent,
          :cancelled,
        )
      end

      it 'matches STATES_NOT_VISIBLE_TO_PROVIDER' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::STATES_NOT_VISIBLE_TO_PROVIDER,
        )
      end
    end

    describe '.visible_to_provider' do
      subject(:scope_method) { described_class.visible_to_provider }

      it 'returns only states that are visible to provider' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :awaiting_provider_decision,
          :withdrawn,
          :rejected,
          :inactive,
          :interviewing,
          :offer,
          :offer_withdrawn,
          :declined,
          :pending_conditions,
          :conditions_not_met,
          :recruited,
          :offer_deferred,
        )
      end

      it 'matches STATES_VISIBLE_TO_PROVIDER' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER,
        )
      end
    end

    describe '.interviewable' do
      subject(:scope_method) { described_class.interviewable }

      it 'returns only states that are interviewable' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :awaiting_provider_decision,
          :inactive,
          :interviewing,
        )
      end

      it 'matches INTERVIEWABLE_STATES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::INTERVIEWABLE_STATES,
        )
      end
    end

    describe '.offer_accepted' do
      subject(:scope_method) { described_class.offer_accepted }

      it 'returns only states that have accepted offers' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :pending_conditions,
          :conditions_not_met,
          :recruited,
          :offer_deferred,
        )
      end

      it 'matches ACCEPTED_STATES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::ACCEPTED_STATES,
        )
      end
    end

    describe '.offered' do
      subject(:scope_method) { described_class.offered }

      it 'returns only states that have offers' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :offer,
          :offer_withdrawn,
          :declined,
          :pending_conditions,
          :conditions_not_met,
          :recruited,
          :offer_deferred,
        )
      end

      it 'matches OFFERED_STATES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::OFFERED_STATES,
        )
      end
    end

    describe '.post_offered' do
      subject(:scope_method) { described_class.post_offered }

      it 'returns only states that are post-offered' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :offer_withdrawn,
          :declined,
          :pending_conditions,
          :conditions_not_met,
          :recruited,
          :offer_deferred,
        )
      end

      it 'matches POST_OFFERED_STATES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::POST_OFFERED_STATES,
        )
      end
    end

    describe '.unsuccessful' do
      subject(:scope_method) { described_class.unsuccessful }

      it 'returns only states that are unsuccessful' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :application_not_sent,
          :cancelled,
          :withdrawn,
          :rejected,
          :inactive,
          :offer_withdrawn,
          :declined,
          :conditions_not_met,
        )
      end

      it 'matches UNSUCCESSFUL_STATES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::UNSUCCESSFUL_STATES,
        )
      end
    end

    describe '.carry_over' do
      subject(:scope_method) { described_class.carry_over }

      it 'returns only states that are eligible for carry over' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :application_not_sent,
          :cancelled,
          :withdrawn,
          :rejected,
          :offer_withdrawn,
          :declined,
          :conditions_not_met,
        )
      end

      it 'matches CARRY_OVER_ELIGIBLE_STATES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::CARRY_OVER_ELIGIBLE_STATES,
        )
      end
    end

    describe '.successful' do
      subject(:scope_method) { described_class.successful }

      it 'returns only states that are successful' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :offer,
          :pending_conditions,
          :recruited,
          :offer_deferred,
        )
      end

      it 'matches SUCCESSFUL_STATES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::SUCCESSFUL_STATES,
        )
      end
    end

    describe '.pending_provider_decision' do
      subject(:scope_method) { described_class.pending_provider_decision }

      it 'returns only states that are pending provider decisions' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :awaiting_provider_decision,
          :interviewing,
        )
      end

      it 'matches DECISION_PENDING_STATUSES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::DECISION_PENDING_STATUSES,
        )
      end
    end

    describe '.pending_provider_decision_or_inactive' do
      subject(:scope_method) { described_class.pending_provider_decision_or_inactive }

      it 'returns only states that are pending provider decisions or are inactive' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :awaiting_provider_decision,
          :interviewing,
          :inactive,
        )
      end

      it 'matches DECISION_PENDING_AND_INACTIVE_STATUSES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::DECISION_PENDING_AND_INACTIVE_STATUSES,
        )
      end
    end

    describe '.reapply' do
      subject(:scope_method) { described_class.reapply }

      it 'returns only states that allow reapplying' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :cancelled,
          :withdrawn,
          :rejected,
          :offer_withdrawn,
          :declined,
        )
      end

      it 'matches REAPPLY_STATUSES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::REAPPLY_STATUSES,
        )
      end
    end

    describe '.terminal' do
      subject(:scope_method) { described_class.terminal }

      it 'returns only states that are terminal' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :application_not_sent,
          :cancelled,
          :withdrawn,
          :rejected,
          :inactive,
          :offer_withdrawn,
          :declined,
          :conditions_not_met,
          :recruited,
        )
      end

      it 'matches TERMINAL_STATES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::TERMINAL_STATES,
        )
      end
    end

    describe '.in_progress' do
      subject(:scope_method) { described_class.in_progress }

      it 'returns only states that are in progress' do
        expect(scope_method.map(&:id)).to contain_exactly(
          :awaiting_provider_decision,
          :interviewing,
          :offer,
          :pending_conditions,
          :recruited,
          :offer_deferred,
        )
      end

      it 'matches IN_PROGRESS_STATES' do
        expect(scope_method.map(&:id)).to match_array(
          ApplicationStateChange::IN_PROGRESS_STATES,
        )
      end
    end
  end

  describe 'states make sense' do
    it 'ensures that no state is both terminal and in progress' do
      skip 'Recruited is both terminal and in progress, so this test is not valid'
      terminal_states = described_class.terminal.map(&:id)
      in_progress_states = described_class.in_progress.map(&:id)

      expect(terminal_states & in_progress_states).to be_empty
    end

    it 'ensures that no state is both successful and unsuccessful' do
      successful_states = described_class.successful.map(&:id)
      unsuccessful_states = described_class.unsuccessful.map(&:id)

      expect(successful_states & unsuccessful_states).to be_empty
    end

    it 'ensures that no state is both pending provider decision and not visible to provider' do
      pending_provider_decision_states = described_class.pending_provider_decision.map(&:id)
      not_visible_to_provider_states = described_class.not_visible_to_provider.map(&:id)

      expect(pending_provider_decision_states & not_visible_to_provider_states).to be_empty
    end
  end

  describe 'awaiting_provider_decision state' do
    subject { described_class.find(:awaiting_provider_decision) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.to be_pending_provider_decision }
    it { is_expected.to be_interviewable }
    it { is_expected.not_to be_offered }
    it { is_expected.not_to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.not_to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.not_to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.to be_in_progress }
    it { is_expected.not_to be_terminal }
  end

  describe 'unsubmitted state' do
    subject { described_class.find(:unsubmitted) }

    it { is_expected.not_to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.not_to be_offered }
    it { is_expected.not_to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.not_to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.not_to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.not_to be_in_progress }
    it { is_expected.not_to be_terminal }
  end

  describe 'application_not_sent state' do
    subject { described_class.find(:application_not_sent) }

    it { is_expected.not_to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.not_to be_offered }
    it { is_expected.not_to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.not_to be_in_progress }
    it { is_expected.to be_terminal }
  end

  describe 'cancelled state' do
    subject { described_class.find(:cancelled) }

    it { is_expected.not_to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.not_to be_offered }
    it { is_expected.not_to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.to be_carry_over }
    it { is_expected.to be_reapply }
    it { is_expected.to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.not_to be_in_progress }
    it { is_expected.to be_terminal }
  end

  describe 'withdrawn state' do
    subject { described_class.find(:withdrawn) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.not_to be_offered }
    it { is_expected.not_to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.to be_carry_over }
    it { is_expected.to be_reapply }
    it { is_expected.to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.not_to be_in_progress }
    it { is_expected.to be_terminal }
  end

  describe 'rejected state' do
    subject { described_class.find(:rejected) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.not_to be_offered }
    it { is_expected.not_to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.to be_carry_over }
    it { is_expected.to be_reapply }
    it { is_expected.to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.not_to be_in_progress }
    it { is_expected.to be_terminal }
  end

  describe 'inactive state' do
    subject { described_class.find(:inactive) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.to be_interviewable }
    it { is_expected.not_to be_offered }
    it { is_expected.not_to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.not_to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.not_to be_in_progress }
    it { is_expected.to be_terminal }
  end

  describe 'interviewing state' do
    subject { described_class.find(:interviewing) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.to be_pending_provider_decision }
    it { is_expected.to be_interviewable }
    it { is_expected.not_to be_offered }
    it { is_expected.not_to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.not_to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.not_to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.to be_in_progress }
    it { is_expected.not_to be_terminal }
  end

  describe 'offer state' do
    subject { described_class.find(:offer) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.to be_offered }
    it { is_expected.not_to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.not_to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.not_to be_unsuccessful }
    it { is_expected.to be_successful }
    it { is_expected.to be_in_progress }
    it { is_expected.not_to be_terminal }
  end

  describe 'offer_withdrawn state' do
    subject { described_class.find(:offer_withdrawn) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.to be_offered }
    it { is_expected.to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.to be_carry_over }
    it { is_expected.to be_reapply }
    it { is_expected.to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.not_to be_in_progress }
    it { is_expected.to be_terminal }
  end

  describe 'declined state' do
    subject { described_class.find(:declined) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.to be_offered }
    it { is_expected.to be_post_offered }
    it { is_expected.not_to be_offer_accepted }
    it { is_expected.to be_carry_over }
    it { is_expected.to be_reapply }
    it { is_expected.to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.not_to be_in_progress }
    it { is_expected.to be_terminal }
  end

  describe 'pending_conditions state' do
    subject { described_class.find(:pending_conditions) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.to be_offered }
    it { is_expected.to be_post_offered }
    it { is_expected.to be_offer_accepted }
    it { is_expected.not_to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.not_to be_unsuccessful }
    it { is_expected.to be_successful }
    it { is_expected.to be_in_progress }
    it { is_expected.not_to be_terminal }
  end

  describe 'conditions_not_met state' do
    subject { described_class.find(:conditions_not_met) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.to be_offered }
    it { is_expected.to be_post_offered }
    it { is_expected.to be_offer_accepted }
    it { is_expected.to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.to be_unsuccessful }
    it { is_expected.not_to be_successful }
    it { is_expected.not_to be_in_progress }
    it { is_expected.to be_terminal }
  end

  describe 'recruited state' do
    subject { described_class.find(:recruited) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.to be_offered }
    it { is_expected.to be_post_offered }
    it { is_expected.to be_offer_accepted }
    it { is_expected.not_to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.not_to be_unsuccessful }
    it { is_expected.to be_successful }
    it { is_expected.to be_in_progress }
    it { is_expected.to be_terminal }
  end

  describe 'offer_deferred state' do
    subject { described_class.find(:offer_deferred) }

    it { is_expected.to be_visible_to_provider }
    it { is_expected.not_to be_pending_provider_decision }
    it { is_expected.not_to be_interviewable }
    it { is_expected.to be_offered }
    it { is_expected.to be_post_offered }
    it { is_expected.to be_offer_accepted }
    it { is_expected.not_to be_carry_over }
    it { is_expected.not_to be_reapply }
    it { is_expected.not_to be_unsuccessful }
    it { is_expected.to be_successful }
    it { is_expected.to be_in_progress }
    it { is_expected.not_to be_terminal }
  end
end

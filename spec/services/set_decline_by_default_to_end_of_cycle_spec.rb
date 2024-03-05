require 'rails_helper'

RSpec.describe SetDeclineByDefaultToEndOfCycle do
  describe '#call' do
    let(:factory_options) { {} }
    let(:application_choice) { create(:application_choice, state, :with_completed_application_form, :continuous_applications, **factory_options) }
    let(:state) { :awaiting_provider_decision }

    subject(:call_service) { described_class.new(application_choice:).call }

    context 'when application choice is awaiting_provider_decision' do
      it 'the DBD is not set for the application_choice' do
        call_service

        expect(application_choice.decline_by_default_at).to be_nil
      end
    end

    context 'when application choice is rejected' do
      let(:state) { :rejected }

      it 'the DBD is not set for the application_choice' do
        call_service

        expect(application_choice.decline_by_default_at).to be_nil
      end
    end

    context 'when the application choice is offered' do
      let(:state) { :offer }

      it 'the DBD is set for the offered application at end of cycle date' do
        expect { call_service }.to change { application_choice.reload.decline_by_default_at }.to(CycleTimetable.next_apply_deadline)
      end
    end

    context 'when the application choice is offered but already has decline_by_default' do
      let(:state) { :offer }

      before { factory_options.merge!({ decline_by_default_at: CycleTimetable.next_apply_deadline }) }

      it 'the DBD is maintained for the offered application at end of cycle date' do
        expect(application_choice.decline_by_default_at).to eq(CycleTimetable.next_apply_deadline)

        expect { call_service }.not_to(change { application_choice.reload.decline_by_default_at })
      end
    end

    context 'when nothing on the record changes' do
      let(:state) { :offer }

      before do
        application_choice
        call_service
      end

      it 'does not update dates when nothing changes', :with_audited do
        expect { call_service }.not_to change(Audited::Audit, :count)
      end
    end
  end
end

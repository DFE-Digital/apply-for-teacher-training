require 'rails_helper'

RSpec.describe EndOfCycle::SendWinterDeclineByDefaultExplainerEmailToCandidatesWorker do
  let(:instance) { described_class.new }
  let(:previous_year) { RecruitmentCycleTimetable.previous_year }

  describe '#perform' do
    context 'before or after the date for sending the winter explainer email' do
      before do
        allow(instance).to receive(:send_emails?).and_return(false)
      end

      it 'does not enqueue the batch worker' do
        create(
          :application_choice,
          :declined_by_default,
          current_recruitment_cycle_year: previous_year,
          application_form: create(:application_form, recruitment_cycle_year: previous_year),
        )
        expect { instance.perform }.not_to enqueue_job(EndOfCycle::SendWinterDeclineByDefaultExplainerEmailToCandidatesBatchWorker)
      end
    end

    context 'the date for sending the explainer email' do
      before do
        allow(instance).to receive(:send_emails?).and_return(true)
      end

      it 'enqueues batch worker' do
        declined_by_default_application = create(:application_form, recruitment_cycle_year: previous_year)
        create(
          :application_choice,
          :declined_by_default,
          application_form: declined_by_default_application,
          current_recruitment_cycle_year: previous_year,
        )

        # These applications should not be included
        create(:application_choice, :inactive, application_form: build(:application_form, recruitment_cycle_year: previous_year))
        create(:application_choice, :interviewing, application_form: build(:application_form, recruitment_cycle_year: previous_year))
        create(:application_choice, :awaiting_provider_decision, application_form: build(:application_form, recruitment_cycle_year: previous_year))
        create(:application_choice, :declined_by_default)

        expect { instance.perform }.to enqueue_job(EndOfCycle::SendWinterDeclineByDefaultExplainerEmailToCandidatesBatchWorker).with(contain_exactly(declined_by_default_application.id))
      end
    end
  end
end

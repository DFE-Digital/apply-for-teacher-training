require 'rails_helper'

RSpec.describe GenerateCandidatePoolData do
  before do
    TestSuiteTimeMachine.travel_permanently_to(
      31.business_days.after(current_timetable.apply_opens_at),
    )
  end

  describe '.call' do
    it 'populated the candidate pool with dummy data' do
      rejected_application_form = create(:application_form, :completed)
      create(:application_choice, :rejected, application_form: rejected_application_form)
      declined_application_form = create(:application_form, :completed)
      create(:application_choice, :declined, application_form: declined_application_form)

      expect { described_class.call }.to change(CandidatePreference, :count).from(0).to(2)
        .and change(CandidatePoolApplication, :count).from(0).to(2)
    end

    context 'when production' do
      it 'does not create any records related to candidate pool' do
        allow(HostingEnvironment).to receive(:production?).and_return(true)
        rejected_application_form = create(:application_form, :completed)
        create(:application_choice, :rejected, application_form: rejected_application_form)
        declined_application_form = create(:application_form, :completed)
        create(:application_choice, :declined, application_form: declined_application_form)

        expect { described_class.call }.to not_change(CandidatePreference, :count)
          .and not_change(CandidatePoolApplication, :count)
      end
    end
  end
end

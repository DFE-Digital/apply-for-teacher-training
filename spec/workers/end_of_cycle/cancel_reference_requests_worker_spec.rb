require 'rails_helper'

RSpec.describe EndOfCycle::CancelReferenceRequestsWorker do
  let(:year) { current_year }
  let(:september_course) { build(:course, start_date: Date.parse("01/09/#{year}")) }
  let(:january_course) { build(:course, start_date: Date.parse("01/01/#{year}")) }
  let(:september_application_choice) do
    create(
      :application_choice,
      current_recruitment_cycle_year: year,
      course_option: build(:course_option, course: september_course),
    )
  end
  let(:january_application_choice) do
    create(
      :application_choice,
      current_recruitment_cycle_year: year - 1,
      course_option: build(:course_option, course: january_course),
    )
  end
  let(:september_reference) { create(:reference, :feedback_requested, application_form: september_application_choice.application_form) }
  let(:january_reference) { create(:reference, :feedback_requested, application_form: january_application_choice.application_form) }
  let(:not_requested_reference) { create(:reference, :not_requested_yet) }
  let(:feedback_refused_reference) { create(:reference, :feedback_refused) }
  let(:email_bounced_reference) { create(:reference, :email_bounced) }
  let(:cancelled_reference) { create(:reference, :cancelled) }
  let(:feedback_provided_reference) { create(:reference, :feedback_provided) }

  before do
    september_reference
    january_reference
    not_requested_reference
    feedback_refused_reference
    email_bounced_reference
    cancelled_reference
    feedback_provided_reference
  end

  describe '#perform' do
    context 'after the decline by default date, and the course starts in september' do
      it 'enqueues secondary worker for references with requested feedback, with a september course', time: decline_by_default_run_date(current_year) do
        allow(EndOfCycle::CancelReferenceRequestsSecondaryWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::CancelReferenceRequestsSecondaryWorker)
          .to have_received(:perform_at).with(kind_of(Time), contain_exactly(september_reference.id))
      end
    end

    context 'after the decline by default date, and the course starting after september' do
      let(:instance) { described_class.new }

      it 'enqueues secondary worker for references with requested feedback, with a january course' do
        allow(instance).to receive(:run_winter_cancel_reference_requests?).and_return(true)
        allow(EndOfCycle::CancelReferenceRequestsSecondaryWorker).to receive(:perform_at)
        instance.perform
        expect(EndOfCycle::CancelReferenceRequestsSecondaryWorker)
          .to have_received(:perform_at).with(kind_of(Time), contain_exactly(january_reference.id))
      end
    end
  end
end

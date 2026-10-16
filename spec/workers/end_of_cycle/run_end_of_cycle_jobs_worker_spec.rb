require 'rails_helper'

RSpec.describe EndOfCycle::RunEndOfCycleJobsWorker do
  describe '#perform' do
    context 'in mid-cycle' do
      it 'does not run any jobs' do
        date = current_timetable.apply_opens_at + 2.months
        travel_temporarily_to(date) do
          described_class.new.perform
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).not_to have_been_enqueued
          expect(EndOfCycle::CloseCoursesOnInvites).not_to have_been_enqueued
          expect(EndOfCycle::RejectByDefaultWorker).not_to have_been_enqueued
          expect(EndOfCycle::DeclineByDefaultWorker).not_to have_been_enqueued
          expect(EndOfCycle::CancelReferenceRequestsWorker).not_to have_been_enqueued
          expect(EndOfCycle::WinterRejectByDefaultWorker).not_to have_been_enqueued
          expect(EndOfCycle::WinterDeclineByDefaultWorker).not_to have_been_enqueued
        end
      end
    end

    context 'after apply deadline, before reject by default date' do
      it 'runs only apply deadline related jobs' do
        date = current_timetable.apply_deadline_at + 1.minute
        travel_temporarily_to(date) do
          described_class.new.perform
          # The winter jobs from the previous year will run
          expect(EndOfCycle::WinterRejectByDefaultWorker).to have_been_enqueued
          expect(EndOfCycle::WinterDeclineByDefaultWorker).to have_been_enqueued
          # These jobs run on the apply deadline
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).to have_been_enqueued.with(true)
          expect(EndOfCycle::CloseCoursesOnInvites).to have_been_enqueued.with(true)
          # Not these
          expect(EndOfCycle::RejectByDefaultWorker).not_to have_been_enqueued
          expect(EndOfCycle::DeclineByDefaultWorker).not_to have_been_enqueued
          expect(EndOfCycle::CancelReferenceRequestsWorker).not_to have_been_enqueued
        end
      end
    end

    context 'after reject by default, before decline by default date' do
      it 'runs apply deadline related jobs and reject by default job' do
        date = current_timetable.reject_by_default_at + 1.minute
        travel_temporarily_to(date) do
          described_class.new.perform
          # The winter jobs from the previous year will run
          expect(EndOfCycle::WinterRejectByDefaultWorker).to have_been_enqueued
          expect(EndOfCycle::WinterDeclineByDefaultWorker).to have_been_enqueued
          # These jobs run on the apply deadline
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).to have_been_enqueued.with(true)
          expect(EndOfCycle::CloseCoursesOnInvites).to have_been_enqueued.with(true)
          # And the reject by default worker
          expect(EndOfCycle::RejectByDefaultWorker).to have_been_enqueued.with(true)
          # Not these
          expect(EndOfCycle::CancelReferenceRequestsWorker).not_to have_been_enqueued
          expect(EndOfCycle::DeclineByDefaultWorker).not_to have_been_enqueued
        end
      end
    end

    context 'after decline by default' do
      it 'runs apply deadline related jobs, reject by default job, and decline by default job' do
        date = current_timetable.decline_by_default_at + 1.minute
        travel_temporarily_to(date) do
          described_class.new.perform
          # The winter jobs from the previous year will run
          expect(EndOfCycle::WinterRejectByDefaultWorker).to have_been_enqueued
          expect(EndOfCycle::WinterDeclineByDefaultWorker).to have_been_enqueued
          # Apply deadline jobs
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).to have_been_enqueued.with(true)
          expect(EndOfCycle::CloseCoursesOnInvites).to have_been_enqueued.with(true)
          # And the reject by default worker
          expect(EndOfCycle::RejectByDefaultWorker).to have_been_enqueued.with(true)
          # And the decline by default worker related jobs
          expect(EndOfCycle::DeclineByDefaultWorker).to have_been_enqueued.with(true)
          expect(EndOfCycle::CancelReferenceRequestsWorker).to have_been_enqueued
        end
      end
    end

    context 'into the next cycle, after the previous cycle winter reject by default at' do
      it 'runs the winter reject by default only' do
        date = current_timetable.winter_reject_by_default_at + 1.minute
        travel_temporarily_to(date) do
          described_class.new.perform
          # The winter reject by default worker will run
          expect(EndOfCycle::WinterRejectByDefaultWorker).to have_been_enqueued
          # But not the winter decline by default worker
          expect(EndOfCycle::WinterDeclineByDefaultWorker).not_to have_been_enqueued
          # Or anything else
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).not_to have_been_enqueued.with(true)
          expect(EndOfCycle::CloseCoursesOnInvites).not_to have_been_enqueued.with(true)
          expect(EndOfCycle::RejectByDefaultWorker).not_to have_been_enqueued.with(true)
          expect(EndOfCycle::DeclineByDefaultWorker).not_to have_been_enqueued.with(true)
          expect(EndOfCycle::CancelReferenceRequestsWorker).not_to have_been_enqueued
        end
      end
    end

    context 'into the next cycle, after the previous cycle winter decline by default at' do
      it 'runs winter jobs only' do
        date = current_timetable.winter_decline_by_default_at + 1.minute
        travel_temporarily_to(date) do
          described_class.new.perform
          # Both winter jobs run
          expect(EndOfCycle::WinterRejectByDefaultWorker).to have_been_enqueued
          expect(EndOfCycle::WinterDeclineByDefaultWorker).to have_been_enqueued
          # But nothing else
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).not_to have_been_enqueued.with(true)
          expect(EndOfCycle::CloseCoursesOnInvites).not_to have_been_enqueued.with(true)
          expect(EndOfCycle::RejectByDefaultWorker).not_to have_been_enqueued.with(true)
          expect(EndOfCycle::DeclineByDefaultWorker).not_to have_been_enqueued.with(true)
          expect(EndOfCycle::CancelReferenceRequestsWorker).not_to have_been_enqueued
        end
      end
    end
  end
end

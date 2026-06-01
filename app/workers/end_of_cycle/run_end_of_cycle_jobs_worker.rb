module EndOfCycle
  class RunEndOfCycleJobsWorker
    include Sidekiq::Worker

    def perform
      if current_timetable.after_apply_deadline?
        EndOfCycle::CancelUnsubmittedApplicationsWorker.perform_async(true)
        EndOfCycle::CloseCoursesOnInvites.perform_async(true)
      end

      if current_timetable.after_reject_by_default?
        EndOfCycle::RejectByDefaultWorker.perform_async(true)
      end

      if current_timetable.after_decline_by_default?
        EndOfCycle::DeclineByDefaultWorker.perform_async(true)
        EndOfCycle::CancelReferenceRequestsWorker.perform_async
      end

      # TODO: Add the Winter reject by / decline by default workers when the dates of been added to database
    end

  private

    def current_timetable
      @current_timetable ||= RecruitmentCycleTimetable.current_timetable
    end
  end
end

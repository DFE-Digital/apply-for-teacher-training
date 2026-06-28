module EndOfCycle
  class RunEndOfCycleJobsWorker < ApplicationJob
    def perform
      if current_timetable.after_apply_deadline?
        EndOfCycle::CancelUnsubmittedApplicationsWorker.perform_later(true)
        EndOfCycle::CloseCoursesOnInvites.perform_later(true)
      end

      if current_timetable.after_reject_by_default?
        EndOfCycle::RejectByDefaultWorker.perform_later(true)
      end

      if current_timetable.after_decline_by_default?
        EndOfCycle::DeclineByDefaultWorker.perform_later(true)
        EndOfCycle::CancelReferenceRequestsWorker.perform_later
      end

      if Time.zone.now.after?(previous_timetable.winter_reject_by_default_at)
        EndOfCycle::WinterRejectByDefaultWorker.perform_async(true)
      end

      if Time.zone.now.after?(previous_timetable.winter_decline_by_default_at)
        EndOfCycle::WinterDeclineByDefaultWorker.perform_async(true)
      end
    end

  private

    def current_timetable
      @current_timetable ||= RecruitmentCycleTimetable.current_timetable
    end

    def previous_timetable
      @previous_timetable ||= current_timetable.relative_previous_timetable
    end
  end
end

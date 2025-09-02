module EndOfCycle
  class CloseCoursesOnInvites
    include Sidekiq::Worker

    def perform(force = false)
      return unless EndOfCycle::JobTimetabler.new.run_cancel_unsubmitted_applications? || force

      Pool::Invite.current_cycle.published.update_all(
        course_open: false,
      )
    end
  end
end

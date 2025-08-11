module EndOfCycle
  class CancelPendingInvitesWorker
    include Sidekiq::Worker

    def perform(force = false)
      return unless EndOfCycle::JobTimetabler.new.cancel_unsubmitted_applications? || force

      Pool::Invite.current_cycle.published.not_responded.update_all(
        status: 'cancelled',
      )
    end
  end
end

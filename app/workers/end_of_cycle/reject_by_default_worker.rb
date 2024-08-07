module EndOfCycle
  class RejectByDefaultWorker
    include Sidekiq::Worker

    def perform
      rejectable_applications.each do |application_form|
        EndOfCycle::RejectByDefaultService.new(application_form).call
      end
    end

  private

    def rejectable_applications
      return [] unless CycleTimetable.run_reject_by_default?

      ApplicationForm
        .current_cycle
        .includes(:application_choices).where('application_choices.status': EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
        .distinct
    end
  end
end

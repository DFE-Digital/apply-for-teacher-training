module EndOfCycle
  class RejectByDefaultWorker
    include Sidekiq::Worker

    def perform
      return unless CycleTimetable.run_reject_by_default?

      rejectable_applications.find_each do |application_form|
        EndOfCycle::RejectByDefaultService.new(application_form).call
      end
    end

  private

    def rejectable_applications
      ApplicationForm
        .current_cycle
        .includes(:application_choices).where('application_choices.status': EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
        .distinct
    end
  end
end

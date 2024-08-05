module EndOfCycle
  class DeclineByDefaultWorker
    include Sidekiq::Worker

    def perform
      declineable_applications.each do |application_form|
        EndOfCycle::DeclineByDefaultService.new(application_form).call
      end
    end

  private

    def declineable_applications
      return [] unless CycleTimetable.run_decline_by_default?

      ApplicationForm
        .current_cycle
        .includes(:application_choices).where('application_choices.status': 'offer')
        .distinct
    end
  end
end

module EndOfCycle
  class DeclineByDefaultWorker
    include Sidekiq::Worker

    def perform
      return unless CycleTimetable.run_decline_by_default?

      declineable_applications.find_each do |application_form|
        EndOfCycle::DeclineByDefaultService.new(application_form).call
      end
    end

  private

    def declineable_applications
      ApplicationForm
        .current_cycle
        .includes(:application_choices).where('application_choices.status': 'offer')
        .distinct
    end
  end
end

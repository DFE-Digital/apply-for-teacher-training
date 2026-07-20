module CandidateMailers
  class SendVisaSponsorshipDeadlineChangeWorker
    include Sidekiq::Worker

    sidekiq_options queue: :mailers

    def perform(application_choice_ids)
      ApplicationChoice.where(id: application_choice_ids).each do |choice|
        application_form = choice.application_form
        course = choice.current_course

        CandidateMailer.visa_sponsorship_deadline_change(
          application_form,
          course,
        ).deliver_later
      end
    end
  end
end

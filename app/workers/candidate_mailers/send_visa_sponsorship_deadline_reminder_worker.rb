module CandidateMailers
  class SendVisaSponsorshipDeadlineReminderWorker
    include Sidekiq::Worker

    sidekiq_options queue: :mailers

    def perform(application_choice_ids)
      ApplicationChoice.where(id: application_choice_ids).each do |choice|
        application_form = choice.application_form
        course = choice.current_course

        ActiveRecord::Base.transaction do
          ChaserSent.create!(
            chased: choice,
            chaser_type: 'visa_sponsorship_deadline',
            course_id: course.id,
          )
          CandidateMailer.visa_sponsorship_deadline_reminder(
            application_form,
            course,
          ).deliver_later
        end
      end
    end
  end
end

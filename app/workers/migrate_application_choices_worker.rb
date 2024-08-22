class MigrateApplicationChoicesWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform(choice_ids)
    errors = []

    ApplicationChoice.find(choice_ids).each do |choice|
      application_form = choice.application_form

      if choice.work_experiences.blank? && application_form.application_work_experiences.any?
        choice.work_experiences = application_form.application_work_experiences.map(&:dup)
      end

      if choice.volunteering_experiences.blank? && application_form.application_volunteering_experiences.any?
        choice.volunteering_experiences = application_form.application_volunteering_experiences.map(&:dup)
      end

      if choice.work_history_breaks.blank? && application_form.application_work_history_breaks.any?
        choice.work_history_breaks = application_form.application_work_history_breaks.map(&:dup)
      end
    rescue ActiveRecord::RecordInvalid => e
      errors << "Error choice id #{choice.id}: #{e.message}"
    end

    if errors
      errors.each do |error|
        Rails.logger.info error
      end

      Rails.logger.info "#{errors.count} errors"
    end

    Rails.logger.info 'No errors' if errors.blank?
  end
end

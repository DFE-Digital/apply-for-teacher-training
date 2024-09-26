class MigrateApplicationChoicesWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform(choice_ids)
    return if HostingEnvironment.production?

    application_experiences = []
    work_history_breaks = []

    ApplicationChoice.where(id: choice_ids).find_each(batch_size: 100) do |choice|
      application_form = choice.application_form

      if choice.work_experiences.blank? && application_form.application_work_experiences.any?
        application_experiences += valid_attributes(
          application_form.application_work_experiences.map(&:dup),
          choice,
          'experienceable',
        )
      end

      if choice.volunteering_experiences.blank? && application_form.application_volunteering_experiences.any?
        application_experiences += valid_attributes(
          application_form.application_volunteering_experiences.map(&:dup),
          choice,
          'experienceable',
        )
      end

      if choice.work_history_breaks.blank? && application_form.application_work_history_breaks.any?
        work_history_breaks += valid_attributes(
          application_form.application_work_history_breaks.map(&:dup),
          choice,
          'breakable',
        )
      end
    end

    ApplicationExperience.insert_all(application_experiences) if application_experiences.any?
    ApplicationWorkHistoryBreak.insert_all(work_history_breaks) if work_history_breaks.any?
  end

private

  def valid_attributes(records, choice, polymorphic_column)
    records.map do |record|
      attributes = record.attributes
      attributes["#{polymorphic_column}_type"] = 'ApplicationChoice'
      attributes["#{polymorphic_column}_id"] = choice.id
      attributes['created_at'] = Time.zone.now
      attributes['updated_at'] = Time.zone.now
      if record.is_a?(ApplicationWorkExperience)
        # We need to get the DB value 'Full time' not the casted value full_time
        attributes['commitment'] = ApplicationWorkExperience.commitments[record.commitment]
      end
      attributes.delete('id')

      attributes
    end
  end
end

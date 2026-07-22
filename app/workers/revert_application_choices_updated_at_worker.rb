class RevertApplicationChoicesUpdatedAtWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform(choice_ids)
    choices_to_update = {}
    timestamps = {}

    ApplicationChoice.where(id: choice_ids).find_each(batch_size: 100) do |choice|
      audits = choice.own_and_associated_audits.order(:created_at)
      touch_audits, user_audits = audits.partition do |audit|
        audit.created_at.between?(Time.zone.parse('2024-9-3 10:00'), Time.zone.parse('2024-9-3 20:00')) &&
          audit.user_type.nil? &&
          audit.user_id.nil? &&
          audit.action == 'create' &&
          audit.username == '(Automated process)' &&
          %w[ApplicationExperience ApplicationWorkHistoryBreak].include?(audit.auditable_type) &&
          audit.associated_type = 'ApplicationChoice'
      end

      next if touch_audits.blank?

      last_created_user_audit = user_audits.first.created_at
      last_created_touch_audit = touch_audits.first.created_at

      if last_created_user_audit.before?(last_created_touch_audit) && choice.updated_at < last_created_touch_audit + 10.seconds
        choices_to_update[choice.id] = choice
        timestamps[choice.id] = last_created_user_audit
      end
    end

    ActiveRecord::Base.transaction do
      choices_to_update.each do |id, choice|
        choice.update_columns(updated_at: timestamps[id])
      end
    end

    log("Updated choice ids: #{choices_to_update.keys}")
  end

private

  def log(message)
    Rails.logger.tagged('Big Touch Fix') do
      Rails.logger.info(message)
    end
  end
end

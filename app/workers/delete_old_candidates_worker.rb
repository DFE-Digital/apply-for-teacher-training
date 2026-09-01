class DeleteOldCandidatesWorker < ApplicationJob
  def perform
    Candidate.where('last_signed_in_at < ?', 7.years.ago).find_in_batches(batch_size: 100) do |batch|
      DeleteCandidatesWorker.perform_later(batch.map(&:id))
    end
  end
end

class DeleteCandidatesWorker < ApplicationJob
  def perform(candidate_ids)
    analytics_tables = YAML.load_file('config/analytics.yml').fetch('shared').keys.map(&:to_s)

    Candidate.where(id: candidate_ids).each do |candidate|
      ActiveRecord::Base.transaction do
        deleted_records = rails_dependent_records(candidate).slice(*analytics_tables).compact_blank

        DeletedCandidate.create!(candidate_id: candidate.id, deleted_records:)
        candidate.without_auditing do
          candidate.destroy!
        end
      end
    end
  end

private

  def rails_dependent_records(candidate)
    hash = {}

    sub = ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      sql = event.payload[:sql]

      if sql.start_with?('DELETE FROM')
        table_name = sql.split('DELETE FROM').last.split('WHERE').first&.strip&.delete('"')
        id = if event.payload[:type_casted_binds].any?
               event.payload[:type_casted_binds].first
             else
               sql.split("DELETE FROM \"#{table_name}\" WHERE \"#{table_name}\".\"id\" = ").last.split.first.to_i
             end

        if hash[table_name].present?
          hash[table_name] << id if hash[table_name].exclude?(id)
        else
          hash[table_name] = [id]
        end
      end
    end

    begin
      ActiveRecord::Base.transaction do
        candidate.destroy!
        raise ActiveRecord::Rollback
      end
    ensure
      ActiveSupport::Notifications.unsubscribe(sub)
    end

    hash
  end
end

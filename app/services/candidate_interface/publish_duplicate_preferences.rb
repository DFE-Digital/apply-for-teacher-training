module CandidateInterface
  class PublishDuplicatePreferences
    def call
      if candidate_ids.blank?
        Rails.logger.debug 'No candidates'
        return
      end

      errors = []

      Candidate.where(id: candidate_ids).find_each do |candidate|
        application_form = candidate.current_application
        duplicated_preference = application_form.duplicated_preferences.last

        ActiveRecord::Base.transaction do
          duplicated_preference.published!
          application_form.duplicated_preferences.where.not(
            id: duplicated_preference.id,
          ).destroy_all
        end

        if duplicated_preference.reload.published? &&
           application_form.emails.where(mail_template: 'publish_duplicated_preference').blank?
          CandidateMailer.publish_duplicated_preference(application_form)
        end
      rescue StandardError => e
        errors << { candidate_id: candidate.id, error: e.message }
        next
      end

      Rails.logger.debug { "Errors: #{errors}" }
    end

    def candidate_ids
      sql = <<-SQL
        SELECT DISTINCT(candidates.id)
        FROM candidates
        INNER JOIN candidate_preferences published_preferences
          ON published_preferences.candidate_id = candidates.id
          AND published_preferences.status = 'published'
          AND published_preferences.pool_status = 'opt_in'
        INNER JOIN candidate_preferences duplicated_preferences
          ON duplicated_preferences.candidate_id = candidates.id
          AND duplicated_preferences.status = 'duplicated'
          AND duplicated_preferences.pool_status = 'opt_in'
        INNER JOIN application_forms
          ON application_forms.candidate_id = candidates.id
        WHERE application_forms.recruitment_cycle_year = 2026
        AND application_forms.submitted_at IS NOT NULL
        AND duplicated_preferences.updated_at > published_preferences.updated_at
      SQL

      results = ActiveRecord::Base.connection.execute(sql)
      results&.field_values(:id)
    end
  end
end

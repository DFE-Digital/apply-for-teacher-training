module CandidateInterface
  class CarryOverPublishedPreference
    IGNORED_ATTRIBUTES = %w[id created_at updated_at status candidate_preference_id].freeze

    def call
      if candidate_ids.blank?
        Rails.logger.debug 'No candidates'
        return
      end

      Candidate.where(id: candidate_ids).find_each do |candidate|
        ActiveRecord::Base.transaction do
          original_application_form = candidate.application_forms
            .where(recruitment_cycle_year: 2025).first
          original_candidate_preference = original_application_form.published_preference
          new_application_form = candidate.current_application

          if original_candidate_preference.present?
            new_candidate_preference = new_application_form.preferences.create!(
              **original_candidate_preference.attributes.except(*IGNORED_ATTRIBUTES),
              status: 'published',
            )
            if original_candidate_preference.training_locations_specific?
              original_candidate_preference.location_preferences.each do |location_preference|
                new_candidate_preference.location_preferences.create!(
                  location_preference.attributes.except(*IGNORED_ATTRIBUTES),
                )
              end
            end
          end
        end
      end
    end

  private

    def candidate_ids
      sql = <<-SQL
        SELECT DISTINCT(candidates.id)
        FROM candidates
        INNER JOIN candidate_preferences published_preferences
         ON published_preferences.candidate_id = candidates.id
           AND published_preferences.status = 'published'
           AND published_preferences.pool_status = 'opt_in'
        INNER JOIN application_forms
          ON application_forms.candidate_id = candidates.id
        INNER JOIN application_forms preferences_application_forms
          ON preferences_application_forms.id = published_preferences.application_form_id
          AND preferences_application_forms.recruitment_cycle_year = 2025
        WHERE application_forms.recruitment_cycle_year = 2026
        AND application_forms.submitted_at IS NOT NULL
        AND published_preferences.updated_at > application_forms.submitted_at
      SQL

      results = ActiveRecord::Base.connection.execute(sql)
      results&.field_values(:id)
    end
  end
end

module Publications
  module MonthlyStatistics
    class Base
    protected

      def application_choices
        ApplicationChoice
          .joins(application_form: :candidate)
          .joins(:current_course)
          .where('candidates.hide_in_reporting IS NOT TRUE')
          .where(current_recruitment_cycle_year: RecruitmentCycle.current_year)
          .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
      end

      def candidate_query(type, phase = nil)
        if type == :by_age_group
          field = 'age_group'

          case_clause = <<~SQL
            CASE
              WHEN f.date_of_birth > '#{Date.new(RecruitmentCycle.current_year - 22, 7, 31)}' THEN '21 and under'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 23, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 22, 7, 31)}' THEN '22'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 24, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 23, 7, 31)}' THEN '23'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 25, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 24, 7, 31)}' THEN '24'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 30, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 25, 7, 31)}' THEN '25 to 29'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 35, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 30, 7, 31)}' THEN '30 to 34'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 40, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 35, 7, 31)}' THEN '35 to 39'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 45, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 40, 7, 31)}' THEN '40 to 44'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 50, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 45, 7, 31)}' THEN '45 to 49'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 55, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 50, 7, 31)}' THEN '50 to 54'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 60, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 55, 7, 31)}' THEN '55 to 59'
              WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 65, 8, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 60, 7, 31)}' THEN '60 to 64'
              WHEN f.date_of_birth < '#{Date.new(RecruitmentCycle.current_year - 65, 8, 1)}' THEN '65 and over'
            END #{field}
          SQL
        elsif type == :by_status
          where_clause = "AND f.phase = '#{phase}'"
        elsif type == :by_area
          field = 'region_code'

          case_clause = <<~SQL
            CASE
              WHEN f.country IS NULL AND f.region_code IS NULL THEN 'no_region'
              WHEN f.region_code IS NOT NULL THEN f.region_code
              WHEN f.country IN (#{EU_EEA_SWISS_COUNTRY_CODES.map { |c| "'#{c}'" }.join(',')}) THEN 'european_economic_area'
              ELSE 'rest_of_the_world'
            END #{field}
          SQL
        elsif type == :by_sex
          field = 'sex'

          case_clause = <<~SQL
            CASE
              WHEN f.equality_and_diversity->>'sex' IS NULL THEN 'Prefer not to say'
              ELSE f.equality_and_diversity->>'sex'
            END sex
          SQL
        end

        <<~SQL
          WITH raw_data AS (
              SELECT
                  c.id,
                  f.id,
                  CASE
                    WHEN 'recruited' = ANY(ARRAY_AGG(ch.status)) THEN 'recruited'
                    WHEN 'pending_conditions' = ANY(ARRAY_AGG(ch.status)) THEN 'pending_conditions'
                    WHEN 'offer_deferred' = ANY(ARRAY_AGG(ch.status)) THEN 'offer_deferred'
                    WHEN 'offer' = ANY(ARRAY_AGG(ch.status)) THEN 'offer'
                    WHEN 'interviewing' = ANY(ARRAY_AGG(ch.status)) THEN 'interviewing'
                    WHEN 'awaiting_provider_decision' = ANY(ARRAY_AGG(ch.status)) THEN 'awaiting_provider_decision'
                    WHEN 'declined' = ANY(ARRAY_AGG(ch.status)) THEN 'declined'
                    WHEN 'offer_withdrawn' = ANY(ARRAY_AGG(ch.status)) THEN 'offer_withdrawn'
                    WHEN 'conditions_not_met' = ANY(ARRAY_AGG(ch.status)) THEN 'conditions_not_met'
                    WHEN 'rejected' = ANY(ARRAY_AGG(ch.status)) THEN 'rejected'
                    WHEN 'withdrawn' = ANY(ARRAY_AGG(ch.status)) THEN 'withdrawn'
                  END status
                  #{case_clause.present? ? ",#{case_clause}" : ''}
                FROM
                  application_forms f
                JOIN
                    candidates c ON f.candidate_id = c.id
                LEFT JOIN
                    application_choices ch ON ch.application_form_id = f.id
                WHERE
                    NOT c.hide_in_reporting
                    AND ch.current_recruitment_cycle_year = #{RecruitmentCycle.current_year}
                    #{where_clause.presence}
                    AND ch.status IN (#{ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.map { |status| "'#{status}'" }.join(',')})
                    AND (
                      NOT EXISTS (
                        SELECT 1
                        FROM application_forms
                        AS subsequent_application_forms
                        WHERE f.id = subsequent_application_forms.previous_application_form_id
                        AND subsequent_application_forms.submitted_at IS NOT NULL
                      )
                    )
                GROUP BY
                    c.id, f.id
          )
          SELECT
              status,
              #{field.present? ? "#{field}," : ''}
              COUNT(*)
          FROM
              raw_data
          GROUP BY
              status #{field.present? ? ",#{field}" : ''}
        SQL
      end

      def candidate_query_by_age_group
        candidate_query(:by_age_group)
      end

      def candidate_query_by_status(phase)
        candidate_query(:by_status, phase)
      end

      def candidate_query_by_area
        candidate_query(:by_area)
      end

      def candidate_query_by_sex
        candidate_query(:by_sex)
      end

      def recruited_count(statuses)
        statuses['recruited'] || 0
      end

      def pending_count(statuses)
        statuses['pending_conditions'] || 0
      end

      def deferred_count(statuses)
        statuses['offer_deferred'] || 0
      end

      def offer_count(statuses)
        (statuses['offer'] || 0)
      end

      def awaiting_decision_count(statuses)
        (statuses['awaiting_provider_decision'] || 0) + (statuses['interviewing'] || 0)
      end

      def unsuccessful_count(statuses)
        (statuses['declined'] || 0) +
          (statuses['rejected'] || 0) +
          (statuses['conditions_not_met'] || 0) +
          (statuses['withdrawn'] || 0) +
          (statuses['offer_withdrawn'] || 0)
      end

      def statuses_count(statuses)
        recruited_count(statuses) +
          pending_count(statuses) +
          deferred_count(statuses) +
          offer_count(statuses) +
          awaiting_decision_count(statuses) +
          unsuccessful_count(statuses)
      end

      def column_totals_for(rows)
        _area, *statuses = rows.first.keys

        statuses.map do |column_name|
          rows.inject(0) { |total, hash| total + hash[column_name] }
        end
      end
    end
  end
end

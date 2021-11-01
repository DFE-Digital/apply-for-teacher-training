module DataAPI
  class TADSubjectsExport
    def self.run_daily
      data_export = DataExport.create!(
        name: 'Weekly export of subjects, candidate nationality, domicile and application status for TAD',
        export_type: :tad_subjects,
      )
      DataExporter.perform_async(DataAPI::TADSubjectsExport, data_export.id)
    end

    def self.all
      DataSubjectsExport
        .where(export_type: :tad_subjects)
        .where.not(completed_at: nil)
    end

    def self.latest
      all.last
    end

    def data_for_export(*)
      counts
    end

    def counts
      @counts ||= ActiveRecord::Base
        .connection
        .execute(query)
        .to_a
    end

  private

    def query
      <<-SQL
        WITH applications AS (
          SELECT
            application_forms.id,
            ARRAY_AGG(subjects.name) subjects,
            CASE
              WHEN 'recruited' = ANY(ARRAY_AGG(application_choices.status)) THEN ARRAY['0', 'recruited']
              WHEN 'offer_deferred' = ANY(ARRAY_AGG(application_choices.status)) THEN ARRAY['1', 'offer_deferred']
              WHEN 'pending_conditions' = ANY(ARRAY_AGG(application_choices.status)) THEN ARRAY['2', 'pending_conditions']
              WHEN 'offer' = ANY(ARRAY_AGG(application_choices.status)) THEN ARRAY['3', 'offer']
              WHEN 'awaiting_provider_decision' = ANY(ARRAY_AGG(application_choices.status)) THEN ARRAY['4', 'awaiting_provider_decision']
              WHEN 'declined' = ANY(ARRAY_AGG(application_choices.status)) THEN ARRAY['5', 'declined']
              WHEN 'rejected' = ANY(ARRAY_AGG(application_choices.status)) THEN ARRAY['6', 'rejected']
              WHEN 'conditions_not_met' = ANY(ARRAY_AGG(application_choices.status)) THEN ARRAY['7', 'conditions_not_met']
            END status,
            CASE
              WHEN first_nationality IS NULL OR first_nationality = '' THEN NULL
              WHEN array[#{uk_nationalities}]::varchar[] && array[first_nationality, second_nationality, third_nationality, fourth_nationality] THEN 'UK'
              WHEN array[#{eu_nationalities}]::varchar[] && array[first_nationality, second_nationality, third_nationality, fourth_nationality] THEN 'EU'
              ELSE 'Not EU'
            END nationality,
            CASE
              WHEN application_forms.country IS NULL OR application_forms.country = '' THEN NULL
              WHEN array[#{uk_country_codes}]::varchar[] && array[application_forms.country] THEN 'UK'
              WHEN array[#{eu_country_codes}]::varchar[] && array[application_forms.country] THEN 'EU'
              ELSE 'Not EU'
            END domicile
            FROM application_choices
            INNER JOIN application_forms ON application_choices.application_form_id = application_forms.id
            INNER JOIN candidates ON application_forms.candidate_id = candidates.id
            INNER JOIN course_options ON application_choices.course_option_id = course_options.id
            INNER JOIN courses ON courses.id = course_options.course_id
            INNER JOIN course_subjects ON courses.id = course_subjects.course_id
            INNER JOIN subjects ON subjects.id = course_subjects.subject_id
            WHERE NOT candidates.hide_in_reporting
              AND application_forms.recruitment_cycle_year = #{RecruitmentCycle.current_year}
              AND (
                NOT EXISTS (
                  SELECT 1
                  FROM application_forms
                  AS subsequent_application_forms
                  WHERE application_forms.id = subsequent_application_forms.previous_application_form_id
                )
              )
            GROUP BY application_forms.id, application_forms.country, application_forms.first_nationality
          )
          SELECT
            applications.status[2],
            applications.subjects,
            applications.nationality,
            applications.domicile,
            COUNT(*)
          FROM
            applications
          GROUP BY
            applications.status,
            applications.subjects,
            applications.nationality,
            applications.domicile
          ORDER BY
            applications.status[1];
      SQL
    end

    def uk_nationalities
      UK_NATIONALITIES.map { |nationality| "'#{nationality}'" }.join(',')
    end

    def uk_country_codes
      "'GB'"
    end

    def eu_nationalities
      EU_COUNTRY_CODES.map { |code| "'#{NATIONALITIES_BY_CODE[code]}'" }.join(',')
    end

    def eu_country_codes
      EU_COUNTRY_CODES.map { |code| "'#{code}'" }.join(',')
    end
  end
end

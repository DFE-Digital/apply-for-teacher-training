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
      result = ActiveRecord::Base
        .connection
        .execute(query)
      result.type_map = type_map
      aggregate_results(result)
    end

  private

    def aggregate_results(results)
      indexed_counts = {}
      results.each do |result|
        result['subject_statuses'].each do |subject, status|
          key = [subject, status, result['domicile'], result['nationality']]
          indexed_counts[key] = (indexed_counts[key] || 0) + 1
        end
      end
      flatten_results(indexed_counts)
    end

    def flatten_results(counts)
      counts.map do |key, count|
        {
          subject: key[0],
          status: key[1],
          domicile: key[2],
          nationality: key[3],
          count: count,
        }
      end
    end

    def type_map
      @type_map ||= PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection)
    end

    def query
      <<-SQL
        SELECT
          application_forms.candidate_id,
          application_forms.id,
          ARRAY_AGG(ARRAY[subjects.name, application_choices.status]) subject_statuses,
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
              (
                NOT EXISTS (
                  SELECT 1
                  FROM application_forms
                  AS subsequent_application_forms
                  WHERE application_forms.id = subsequent_application_forms.previous_application_form_id
                )
              )
              OR application_forms.phase = 'apply_1'
            )
          GROUP BY application_forms.candidate_id, application_forms.id, nationality, domicile
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

module DataAPI
  class TADSubjectDomicileNationalityExport
    def self.run_weekly
      data_export = DataExport.create!(
        name: 'Weekly export of subjects, candidate nationality, domicile and application status for TAD',
        export_type: :tad_subject_domicile_nationality,
      )
      DataExporter.perform_async(DataAPI::TADSubjectDomicileNationalityExport.to_s, data_export.id)
    end

    def self.all
      DataSubjectsExport
        .where(export_type: :tad_subject_domicile_nationality)
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
        status, subjects = subjects_for_most_progressed_statuses(
          subjects_indexed_by_status(result),
        )

        subjects.each do |subject|
          key = [subject, result['domicile'], result['nationality']]
          indexed_counts[key] ||= {
            adjusted_applications: 0,
            adjusted_offers: 0,
            pending_conditions: 0,
            recruited: 0,
          }

          increment_counts(indexed_counts, key, status, subjects.count)
        end
      end
      roundup_results(flatten_results(indexed_counts))
    end

    def subjects_indexed_by_status(result)
      subjects_indexed_by_status = {}
      result['subject_statuses'].each do |subject, status|
        subjects_indexed_by_status[status.to_sym] ||= []
        subjects_indexed_by_status[status.to_sym] << subject
      end
      subjects_indexed_by_status
    end

    def subjects_for_most_progressed_statuses(subjects_indexed_by_status)
      if subjects_indexed_by_status.key?(:recruited)
        subjects_indexed_by_status.select! { |status| status == :recruited }
      elsif subjects_indexed_by_status.key?(:pending_conditions)
        subjects_indexed_by_status.select! { |status| status == :pending_conditions }
      elsif subjects_indexed_by_status.key?(:offer)
        subjects_indexed_by_status.select! { |status| status == :offer }
      else
        subjects_indexed_by_status = { other: subjects_indexed_by_status.values.flatten }
      end
      status, subjects = subjects_indexed_by_status.to_a.first

      [status, subjects]
    end

    def increment_counts(indexed_counts, key, status, count)
      case status
      when :recruited
        indexed_counts[key][:recruited] += 1
      when :pending_conditions
        indexed_counts[key][:pending_conditions] += 1
      when :offer
        indexed_counts[key][:adjusted_offers] += (1 / count.to_f)
      else
        indexed_counts[key][:adjusted_applications] += (1 / count.to_f)
      end
    end

    def flatten_results(counts)
      counts.map do |key, count|
        {
          subject: key[0],
          candidate_domicile: key[1],
          candidate_nationality: key[2],
        }.merge(count)
      end
    end

    def roundup_results(counts)
      counts.map do |count|
        count.merge(
          recruited: count[:recruited].ceil,
          pending_conditions: count[:pending_conditions].ceil,
          adjusted_offers: count[:adjusted_offers].ceil,
          adjusted_applications: count[:adjusted_applications].ceil,
        )
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
            WHEN application_forms.first_nationality IS NULL OR application_forms.first_nationality = '' THEN NULL
            WHEN array[#{uk_nationalities}]::varchar[] && array[application_forms.first_nationality, application_forms.second_nationality, application_forms.third_nationality, application_forms.fourth_nationality] THEN 'UK'
            WHEN array[#{eu_nationalities}]::varchar[] && array[application_forms.first_nationality, application_forms.second_nationality, application_forms.third_nationality, application_forms.fourth_nationality] THEN 'EU'
            ELSE 'Not EU'
          END nationality,
          CASE
            WHEN application_forms.country IS NULL OR application_forms.country = '' THEN NULL
            WHEN application_forms.country IN (#{uk_country_codes}) THEN 'UK'
            WHEN application_forms.country IN (#{eu_country_codes}) THEN 'EU'
            ELSE 'Not EU'
          END domicile
          FROM application_choices
          INNER JOIN application_forms ON application_choices.application_form_id = application_forms.id
          INNER JOIN candidates ON application_forms.candidate_id = candidates.id
          INNER JOIN course_options ON application_choices.course_option_id = course_options.id
          INNER JOIN courses ON courses.id = course_options.course_id
          INNER JOIN course_subjects ON courses.id = course_subjects.course_id
          INNER JOIN subjects ON subjects.id = course_subjects.subject_id
          LEFT OUTER JOIN application_forms as subsequent_application_forms
            ON application_forms.id = subsequent_application_forms.previous_application_form_id
          WHERE NOT candidates.hide_in_reporting
            AND application_forms.recruitment_cycle_year = #{current_year}
            AND (
              application_forms.phase = 'apply_1'
              OR subsequent_application_forms.id is null
            )
          GROUP BY application_forms.candidate_id, application_forms.id, nationality, domicile
      SQL
    end

    def current_year
      @current_year ||= RecruitmentCycleTimetable.current_year
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

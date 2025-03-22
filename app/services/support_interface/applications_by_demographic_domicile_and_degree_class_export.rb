module SupportInterface
  class ApplicationsByDemographicDomicileAndDegreeClassExport
    STRUCTURED_DEGREE_CLASSES = ['First class honours', 'Upper second-class honours (2:1)', 'Lower second-class honours (2:2)', 'Third-class honours', 'Pass'].freeze

    def self.run_weekly
      data_export = DataExport.create!(
        name: 'Weekly export of the tad applications by demographic domicile and degree class',
        export_type: :applications_by_demographic_domicile_and_degree_class,
      )
      DataExporter.perform_async(SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport.to_s, data_export.id)
    end

    def call(*)
      results = ActiveRecord::Base
        .connection
        .execute(query)
        .to_a

      aggregate_results(results)
    end

    alias data_for_export call

  private

    def aggregate_results(results)
      indexed_counts = {}
      results.each do |result|
        key = [
          result['age_group'],
          result['sex'],
          result['ethnicity'],
          transform_disability_value(result['disability']),
          STRUCTURED_DEGREE_CLASSES[result['degree_class'].to_i],
          result['domicile'],
        ]
        unless indexed_counts.include?(key)
          indexed_counts[key] ||= {
            pending_conditions: 0,
            recruited: 0,
            total: 0,
          }
        end
        increment_counts(indexed_counts, key, result['status'], result['count'])
      end
      flatten_results(indexed_counts)
    end

    def transform_disability_value(disability)
      unescaped_array = Array.class_eval(disability)

      if unescaped_array.count > 1
        'Two or more impairments and/or disabling medical conditions'
      else
        unescaped_array[0]
      end
    end

    def increment_counts(indexed_counts, key, status, count)
      case status
      when 'recruited'
        indexed_counts[key][:recruited] += count
      when 'pending_conditions'
        indexed_counts[key][:pending_conditions] += count
      end
      indexed_counts[key][:total] += count
    end

    def flatten_results(counts)
      counts.map do |key, count|
        {
          age_group: key[0],
          sex: key[1],
          ethnicity: key[2],
          disability: key[3],
          degree_class: key[4],
          domicile: key[5],
        }.merge(count)
      end
    end

    def query
      <<-SQL
        WITH raw_data AS (
            SELECT
                f.id,
                f.equality_and_diversity->> 'hesa_ethnicity' ethnicity,
                f.equality_and_diversity->> 'hesa_disabilities' disability,

                CASE
                  WHEN 'recruited' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['0', 'recruited']
                  WHEN 'pending_conditions' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['1', 'pending_conditions']
                END status,
                CASE
                  #{age_group_sql}
                END age_group,
                CASE
                  #{equality_and_diversity_sql}
                END sex,
                MIN(
                  CASE
                    #{degree_class_sql}
                  END
                ) degree_class,
                CASE
                  #{domicile_sql}
                END domicile
            FROM
                application_forms f
            LEFT JOIN
                candidates c ON f.candidate_id = c.id
            INNER JOIN
                application_choices ch ON ch.application_form_id = f.id
            INNER JOIN
              application_qualifications q ON q.application_form_id = f.id
            WHERE
                NOT c.hide_in_reporting
                AND f.recruitment_cycle_year = #{current_year}
                AND f.date_of_birth IS NOT NULL
                AND f.submitted_at IS NOT NULL
                AND phase = 'apply_1'
                AND q.level = 'degree'
                AND (
                  NOT EXISTS (
                    SELECT 1
                    FROM application_forms
                    AS subsequent_application_forms
                    WHERE f.id = subsequent_application_forms.previous_application_form_id
                  )
                )
            GROUP BY
                f.id, age_group, domicile, sex
        )
        SELECT
            raw_data.age_group[2],
            raw_data.sex,
            raw_data.ethnicity,
            raw_data.disability,
            raw_data.degree_class,
            raw_data.domicile,
            COUNT(*),
            raw_data.status[2]
        FROM
            raw_data
        WHERE
            NOT raw_data.disability = '[]'
            AND raw_data.disability IS NOT NULL
            AND raw_data.ethnicity IS NOT NULL
            AND raw_data.status IS NOT NULL
            AND raw_data.degree_class IS NOT NULL
        GROUP BY
            raw_data.age_group,
            raw_data.sex,
            raw_data.ethnicity,
            raw_data.disability,
            raw_data.domicile,
            raw_data.status,
            raw_data.degree_class
        ORDER BY
            raw_data.age_group[1],
            degree_class
      SQL
    end

    def age_group_sql
      "WHEN f.date_of_birth > '#{Date.new(current_year - 25, 7, 31)}' THEN ARRAY['0', 'Under 25']
      WHEN f.date_of_birth BETWEEN '#{Date.new(current_year - 30, 8, 1)}' AND '#{Date.new(current_year - 25, 7, 31)}' THEN ARRAY['1', '25 to 29']
      WHEN f.date_of_birth BETWEEN '#{Date.new(current_year - 35, 8, 1)}' AND '#{Date.new(current_year - 30, 7, 31)}' THEN ARRAY['2', '30 to 34']
      WHEN f.date_of_birth BETWEEN '#{Date.new(current_year - 40, 8, 1)}' AND '#{Date.new(current_year - 35, 7, 31)}' THEN ARRAY['3', '35 to 39']
      WHEN f.date_of_birth BETWEEN '#{Date.new(current_year - 45, 8, 1)}' AND '#{Date.new(current_year - 40, 7, 31)}' THEN ARRAY['4', '40 to 44']
      WHEN f.date_of_birth BETWEEN '#{Date.new(current_year - 50, 8, 1)}' AND '#{Date.new(current_year - 45, 7, 31)}' THEN ARRAY['5', '45 to 49']
      WHEN f.date_of_birth BETWEEN '#{Date.new(current_year - 55, 8, 1)}' AND '#{Date.new(current_year - 50, 7, 31)}' THEN ARRAY['6', '50 to 54']
      WHEN f.date_of_birth < '#{Date.new(current_year - 55, 8, 1)}' THEN ARRAY['7', '55 and over']"
    end

    def equality_and_diversity_sql
      "WHEN f.equality_and_diversity is NULL THEN 'Not provided'
      WHEN f.equality_and_diversity->> 'sex' = 'male' then 'Male'
      WHEN f.equality_and_diversity->> 'sex' = 'female' then 'Female'
      WHEN f.equality_and_diversity->> 'sex' = 'other' then 'Other'
      WHEN f.equality_and_diversity->> 'sex' = 'intersex' then 'Other'
      WHEN f.equality_and_diversity->> 'sex' = 'Prefer not to say' then 'Prefer not to say'"
    end

    def domicile_sql
      "WHEN f.country = 'GB' THEN 'UK'
      WHEN f.country IN (#{EU_COUNTRY_CODES.map { |country| "'#{country}'" }.join(',')}) THEN 'EU'
      ELSE
     'Non EU'"
    end

    def degree_class_sql
      "WHEN q.grade = 'First class honours' THEN 0
      WHEN q.grade = 'First-class honours' THEN 0
      WHEN q.grade = 'Upper second-class honours (2:1)' THEN 1
      WHEN q.grade = 'Lower second-class honours (2:2)' THEN 2
      WHEN q.grade = 'Third-class honours' THEN 3
      WHEN q.grade = 'Pass' THEN 4"
    end

    def current_year
      @current_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end

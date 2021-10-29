module SupportInterface
  class ExternalReportApplicationsExport
    def data_for_export(*)
      hash = create_base_hash

      counts.each do |item|
        course_type = item['course_type']
        age_group = item['age_group']
        subject = item['subject']
        provider_area = item['provider_area']
        count = item['count']

        hash[course_type][age_group][subject][provider_area] += count
      end

      output = []

      hash.each do |course_type, age_groups|
        age_groups.each do |age_group, subjects|
          subjects.each do |subject, provider_areas|
            provider_areas.each do |provider_area, count|
              output << {
                'Course type' => course_type,
                'Age group' => age_group,
                'Subject' => subject,
                'Provider area' => provider_area,
                'Total' => count,
              }
            end
          end
        end
      end

      output.sort_by { |row| [row['Course type'], row['Age group'], row['Subject'], row['Provider area']] }
    end

  private

    def create_base_hash
      hash = {}

      ExternalReportApplications::COURSE_TYPES.each do |course_type|
        hash[course_type] = {}
        hash[course_type][ExternalReportApplications::PRIMARY_AGE_GROUP] = {}
        hash[course_type][ExternalReportApplications::SECONDARY_AGE_GROUP] = {}
        hash[course_type][ExternalReportApplications::FURTHER_EDUCATION_AGE_GROUP] = {}
        hash[course_type][ExternalReportApplications::FURTHER_EDUCATION_AGE_GROUP][ExternalReportApplications::FURTHER_EDUCATION_SUBJECT] = {}

        ExternalReportApplications::PRIMARY_SUBJECTS.each do |subject|
          hash[course_type][ExternalReportApplications::PRIMARY_AGE_GROUP][subject] = {}
          ExternalReportApplications::PROVIDER_AREAS.each do |provider_area|
            hash[course_type][ExternalReportApplications::PRIMARY_AGE_GROUP][subject][provider_area] = 0
          end
        end

        ExternalReportApplications::SECONDARY_SUBJECTS.each do |subject|
          hash[course_type][ExternalReportApplications::SECONDARY_AGE_GROUP][subject] = {}
          ExternalReportApplications::PROVIDER_AREAS.each do |provider_area|
            hash[course_type][ExternalReportApplications::SECONDARY_AGE_GROUP][subject][provider_area] = 0
          end
        end

        ExternalReportApplications::PROVIDER_AREAS.each do |provider_area|
          hash[course_type][ExternalReportApplications::FURTHER_EDUCATION_AGE_GROUP][ExternalReportApplications::FURTHER_EDUCATION_SUBJECT][provider_area] = 0
        end
      end

      hash
    end

    def counts
      @counts ||= ActiveRecord::Base
        .connection
        .execute(query)
        .to_a
    end

    def query
      <<-SQL
        WITH raw_data AS (
            SELECT
                candidates.id,
                f.id,
                ac.id,
                CASE
                  WHEN c.program_type = 'HE' THEN 'Higher education'
                  WHEN c.program_type = 'TA' THEN 'Postgraduate teaching apprenticeship'
                  WHEN c.program_type = 'SC' THEN 'School-centred initial teacher training (SCITT)'
                  WHEN c.program_type = 'SD' THEN 'School Direct (fee-paying)'
                  WHEN c.program_type = 'SS' THEN 'School Direct (salaried)'
                END course_type,
                c.level age_group,
                CASE
                  WHEN 'Art and design' = ANY(ARRAY_AGG(s.name)) THEN 'Art, or Art and design'
                  WHEN array['French', 'German', 'Italian', 'Japanese', 'Mandarin', 'Modern languages (other)', 'Russian', 'Spanish']::varchar[] && ARRAY_AGG(s.name) THEN 'Modern Languages'
                  ELSE
                    s.name
                END subject,
                CASE
                  WHEN p.region_code = 'eastern' THEN 'East'
                  WHEN p.region_code = 'east_midlands' THEN 'East Midlands'
                  WHEN p.region_code = 'london' THEN 'London'
                  WHEN p.region_code = 'north_east' THEN 'North East'
                  WHEN p.region_code = 'north_west' THEN 'North West'
                  WHEN p.region_code = 'south_east' THEN 'South East'
                  WHEN p.region_code = 'south_west' THEN 'South West'
                  WHEN p.region_code = 'west_midlands' THEN 'West Midlands'
                  WHEN p.region_code = 'yorkshire_and_the_humber' THEN 'Yorkshire and The Humber'
                END provider_area
            FROM
                application_choices ac
            LEFT JOIN
                application_forms f ON f.id = ac.application_form_id
            LEFT JOIN
                course_options co ON co.id = ac.current_course_option_id
            LEFT JOIN
                sites ON sites.id = co.site_id
            LEFT JOIN
                providers p ON p.id = sites.provider_id
            LEFT JOIN
                courses c ON c.id = co.course_id
            LEFT JOIN
                course_subjects cs ON cs.course_id = c.id
            LEFT JOIN
                subjects s ON s.id = cs.subject_id
            LEFT JOIN
                candidates ON f.candidate_id = candidates.id
            WHERE
                NOT candidates.hide_in_reporting
                AND f.recruitment_cycle_year = #{RecruitmentCycle.current_year}
            GROUP BY
                candidates.id, ac.id, f.id, co.id, sites.id, p.id, c.id, cs.id, s.id
        )
        SELECT
            raw_data.course_type,
            raw_data.age_group,
            raw_data.subject,
            raw_data.provider_area,
            COUNT(*)
        FROM
            raw_data
        GROUP BY
            raw_data.course_type,
            raw_data.age_group,
            raw_data.subject,
            raw_data.provider_area
        ORDER BY
            raw_data.course_type,
            raw_data.age_group,
            raw_data.subject,
            raw_data.provider_area
      SQL
    end
  end
end

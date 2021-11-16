module SupportInterface
  class ExternalReportCandidatesExport
    def data_for_export(*)
      hash = create_base_hash

      counts.each do |item|
        sex = item['sex']
        area = item['area']
        age_group = item['age_group']
        status = item['status']
        count = item['count']

        hash[sex][area][age_group][status] += count
      end

      output = []

      hash.each do |sex, areas|
        areas.each do |area, age_groups|
          age_groups.each do |age_group, statuses|
            statuses.each do |status, count|
              output << {
                'Sex' => sex,
                'Area' => area,
                'Age group' => age_group,
                'Status' => status,
                'Total' => count >= 5 ? count : '0 to 4',
              }
            end
          end
        end
      end

      output
    end

  private

    def create_base_hash
      hash = {}

      ExternalReportCandidates::SEX.each_value do |sex|
        hash[sex] = {}
        ExternalReportCandidates::AREAS.each_value do |area|
          hash[sex][area] = {}
          ExternalReportCandidates::AGE_GROUPS.each do |age_group|
            hash[sex][area][age_group] = {}
            ExternalReportCandidates::STATUSES.each do |status|
              hash[sex][area][age_group][status] = 0
            end
          end
        end
      end

      hash
    end

    def counts
      @counts ||= ActiveRecord::Base
        .connection
        .execute(query)
        .to_a
        .reject { |row| row.values.include?('offer_deferred') }
    end

    def query
      <<-SQL
        WITH raw_data AS (
            SELECT
                c.id,
                f.id,
                CASE
                  WHEN f.equality_and_diversity is NULL THEN 'Not provided'
                  WHEN f.equality_and_diversity->> 'sex' = 'intersex' then 'Intersex'
                  WHEN f.equality_and_diversity->> 'sex' = 'male' then 'Male'
                  WHEN f.equality_and_diversity->> 'sex' = 'female' then 'Female'
                  WHEN f.equality_and_diversity->> 'sex' = 'Prefer not to say' then 'Prefer not to say'
                END sex,
                CASE
                  WHEN f.region_code = 'channel_islands' THEN 'Channel Islands'
                  WHEN f.region_code = 'eastern' THEN 'East'
                  WHEN f.region_code = 'east_midlands' THEN 'East Midlands'
                  WHEN f.region_code = 'isle_of_man' THEN 'Isle of Man'
                  WHEN f.region_code = 'london' THEN 'London'
                  WHEN f.region_code = 'NULL' THEN 'No region'
                  WHEN f.region_code = 'north_east' THEN 'North East'
                  WHEN f.region_code = 'north_west' THEN 'North West'
                  WHEN f.region_code = 'northern_ireland' THEN 'Northern Ireland'
                  WHEN f.region_code = 'scotland' THEN 'Scotland'
                  WHEN f.region_code = 'south_east' THEN 'South East'
                  WHEN f.region_code = 'south_west' THEN 'South West'
                  WHEN f.region_code = 'wales' THEN 'Wales'
                  WHEN f.region_code = 'west_midlands' THEN 'West Midlands'
                  WHEN f.region_code = 'yorkshire_and_the_humber' THEN 'Yorkshire and The Humber'
                  WHEN f.region_code = 'european_economic_area' THEN 'European Economic Area'
                  WHEN f.region_code = 'rest_of_the_world' THEN 'Rest of the World'
                  ELSE
                    'No region'
                END area,
                CASE
                  WHEN f.date_of_birth > '#{Date.new(RecruitmentCycle.current_year - 22, 8, 31)}' THEN '21 and under'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 23, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 22, 8, 31)}' THEN '22'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 24, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 23, 8, 31)}' THEN '23'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 25, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 24, 8, 31)}' THEN '24'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 30, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 25, 8, 31)}' THEN '25 to 29'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 35, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 30, 8, 31)}' THEN '30 to 34'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 40, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 35, 8, 31)}' THEN '35 to 39'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 45, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 40, 8, 31)}' THEN '40 to 44'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 50, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 45, 8, 31)}' THEN '45 to 49'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 55, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 50, 8, 31)}' THEN '50 to 54'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 60, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 55, 8, 31)}' THEN '55 to 59'
                  WHEN f.date_of_birth BETWEEN '#{Date.new(RecruitmentCycle.current_year - 65, 9, 1)}' AND '#{Date.new(RecruitmentCycle.current_year - 60, 8, 31)}' THEN '60 to 64'
                  WHEN f.date_of_birth < '#{Date.new(RecruitmentCycle.current_year - 65, 9, 1)}' THEN '65 and over'
                END age_group,
                CASE
                  WHEN 'recruited' = ANY(ARRAY_AGG(ac.status_before_deferral)) THEN 'Recruited'
                  WHEN 'pending_conditions' = ANY(ARRAY_AGG(ac.status_before_deferral)) THEN 'Conditions pending'
                  WHEN 'recruited' = ANY(ARRAY_AGG(ac.status)) THEN 'Recruited'
                  WHEN 'offer_deferred' = ANY(ARRAY_AGG(ac.status)) THEN 'offer_deferred'
                  WHEN 'pending_conditions' = ANY(ARRAY_AGG(ac.status)) THEN 'Conditions pending'
                  WHEN 'interviewing' = ANY(ARRAY_AGG(ac.status)) THEN 'Received an offer'
                  WHEN 'offer' = ANY(ARRAY_AGG(ac.status)) THEN 'Received an offer'
                  WHEN 'awaiting_provider_decision' = ANY(ARRAY_AGG(ac.status)) THEN 'Awaiting provider decisions'
                  WHEN 'declined' = ANY(ARRAY_AGG(ac.status)) THEN 'Unsuccessful'
                  WHEN 'rejected' = ANY(ARRAY_AGG(ac.status)) THEN 'Unsuccessful'
                  WHEN 'conditions_not_met' = ANY(ARRAY_AGG(ac.status)) THEN 'Unsuccessful'
                  WHEN 'offer_withdrawn' = ANY(ARRAY_AGG(ac.status)) THEN 'Unsuccessful'
                  WHEN 'withdrawn' = ANY(ARRAY_AGG(ac.status)) THEN 'Unsuccessful'
                END status
            FROM
                application_forms f
            LEFT JOIN
                application_choices ac ON ac.application_form_id = f.id
            LEFT JOIN
                candidates c ON f.candidate_id = c.id
            WHERE
                NOT c.hide_in_reporting
                AND f.submitted_at IS NOT NULL
                AND f.date_of_birth IS NOT NULL
                AND (
                  NOT EXISTS (
                    SELECT 1
                    FROM application_forms
                    AS subsequent_application_forms
                    WHERE f.id = subsequent_application_forms.previous_application_form_id
                  )
                )
                AND (
                  f.recruitment_cycle_year = #{RecruitmentCycle.current_year}
                  OR f.recruitment_cycle_year = #{RecruitmentCycle.previous_year}
                  AND ac.status_before_deferral IS NOT NULL
              )
            GROUP BY
                c.id, f.id
        )
        SELECT
            raw_data.sex,
            raw_data.area,
            raw_data.age_group,
            raw_data.status,
            COUNT(*)
        FROM
            raw_data
        GROUP BY
            raw_data.sex,
            raw_data.area,
            raw_data.age_group,
            raw_data.status
      SQL
    end
  end
end

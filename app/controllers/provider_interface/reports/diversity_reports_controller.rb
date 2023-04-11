module ProviderInterface
  module Reports
    class DiversityReportsController < ProviderInterfaceController
      include CSVNameHelper

      def show
        @provider = current_user.providers.find(provider_id)
        @diversity_report_sex_data = sex_data
        @diversity_report_disability_data = disability_data
        @diversity_report_ethnicity_data = ethnicity_data
        @diversity_report_age_data = age_data
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end

      def sex_data
        sex_data_query.map do |data|
          {
            header: data['sex'],
            values: [data['applied'], data['offered'], data['recruited'], data['percentage']],
          }
        end
      end

      def disability_data
        disability_data_query.map do |data|
          {
            header: data['disability'],
            values: [data['applied'], data['offered'], data['recruited'], data['percentage']],
          }
        end
      end

      def ethnicity_data
        ethnicity_data_query.map do |data|
          {
            header: data['ethnicity'],
            values: [data['applied'], data['offered'], data['recruited'], data['percentage']],
          }
        end
      end

      def age_data
        age_data_query.map do |data|
          {
            header: data['age'],
            values: [data['applied'], data['offered'], data['recruited'], data['percentage']],
          }
        end
      end

      def sex_data_query
        ActiveRecord::Base.connection.exec_query(
          "SELECT
            INITCAP(af.equality_and_diversity ->> 'sex') AS Sex,
            COUNT(DISTINCT CASE WHEN a.status = 'offer' THEN a.id END) AS Offered,
            COUNT(DISTINCT CASE WHEN a.status = 'recruited' THEN a.id END) AS Recruited,
            COUNT(DISTINCT a.id) AS Applied,
            CONCAT(
              ROUND(
                (COUNT(DISTINCT CASE WHEN a.status = 'recruited' THEN a.id END) / COUNT(DISTINCT a.id)::numeric) * 100,
                2
              ),
              '%'
            ) AS Percentage
          FROM
            application_forms af
            JOIN application_choices a ON a.application_form_id = af.id
          WHERE
            af.recruitment_cycle_year = '2023'
          GROUP BY
            af.equality_and_diversity ->> 'sex'",
        ).to_a
      end

      def disability_data_query
        ActiveRecord::Base.connection.exec_query(
          "SELECT
            CASE
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%Autistic spectrum condition%' OR af.equality_and_diversity ->> 'disabilities' LIKE '%speech, language, communication or social skills%' THEN 'Autistic spectrum condition or another condition affecting speech, language, communication or social skills'
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%Blindness%' THEN 'Blindness or a visual impairment not corrected by glasses'
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%motor, cognitive, social and emotional skills, speech or language since childhood%' THEN 'Condition affecting motor, cognitive, social and emotional skills, speech or language since childhood'
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%Deafness%' THEN 'Deafness or a serious hearing impairment'
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%Dyslexia%' OR af.equality_and_diversity ->> 'disabilities' LIKE '%Dyspraxia%' OR af.equality_and_diversity ->> 'disabilities' LIKE '%ADHD%' THEN 'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference'
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%Long-term illness%' THEN 'Long-term illness'
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%Mental health condition%' THEN 'Mental health condition'
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%Physical disability%' OR af.equality_and_diversity ->> 'disabilities' LIKE '%mobility issue%' THEN 'Physical disability or mobility issue'
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%Another disability%' THEN 'Another disability, health condition or impairment affecting daily life'
              WHEN af.equality_and_diversity ->> 'disabilities' LIKE '%I do not have any of these disabilities%' THEN 'I do not have any of these disabilities or health conditions'
              ELSE 'Prefer not to say'
            END AS Disability,
            COUNT(DISTINCT CASE WHEN a.status = 'offer' THEN a.id END) AS Offered,
            COUNT(DISTINCT CASE WHEN a.status = 'recruited' THEN a.id END) AS Recruited,
            COUNT(DISTINCT a.id) AS Applied,
            CONCAT(
              ROUND(
                (COUNT(DISTINCT CASE WHEN a.status = 'recruited' THEN a.id END) / COUNT(DISTINCT a.id)::numeric) * 100,
                2
              ),
              '%'
            ) AS Percentage
          FROM
            application_forms af
            JOIN application_choices a ON a.application_form_id = af.id
          WHERE
            af.recruitment_cycle_year = '2023'
          GROUP BY
            Disability",
        ).to_a
      end

      def ethnicity_data_query
        ActiveRecord::Base.connection.exec_query(
          "SELECT
            af.equality_and_diversity ->> 'ethnic_group' AS Ethnicity,
            COUNT(DISTINCT CASE WHEN a.status = 'offer' THEN a.id END) AS Offered,
            COUNT(DISTINCT CASE WHEN a.status = 'recruited' THEN a.id END) AS Recruited,
            COUNT(DISTINCT a.id) AS Applied,
            CONCAT(
              ROUND(
                (COUNT(DISTINCT CASE WHEN a.status = 'recruited' THEN a.id END) / COUNT(DISTINCT a.id)::numeric) * 100,
                2
              ),
              '%'
            ) AS Percentage
          FROM
            application_forms af
            JOIN application_choices a ON a.application_form_id = af.id
          WHERE
            af.recruitment_cycle_year = '2023'
          GROUP BY
            af.equality_and_diversity ->> 'ethnic_group'",
        ).to_a
      end

      def age_data_query
        ActiveRecord::Base.connection.exec_query(
          "SELECT
            CASE
              WHEN date_part('year', age(now(), af.date_of_birth)) BETWEEN 18 AND 24 THEN '18 to 24'
              WHEN date_part('year', age(now(), af.date_of_birth)) BETWEEN 25 AND 34 THEN '25 to 34'
              WHEN date_part('year', age(now(), af.date_of_birth)) BETWEEN 35 AND 44 THEN '35 to 44'
              WHEN date_part('year', age(now(), af.date_of_birth)) BETWEEN 45 AND 54 THEN '45 to 54'
              WHEN date_part('year', age(now(), af.date_of_birth)) BETWEEN 55 AND 64 THEN '55 to 64'
              WHEN extract(year from age(af.date_of_birth)) >= 65 THEN '65 and over'
            END AS Age,
            COUNT(DISTINCT CASE WHEN a.status = 'offer' THEN a.id END) AS Offered,
            COUNT(DISTINCT CASE WHEN a.status = 'recruited' THEN a.id END) AS Recruited,
            COUNT(DISTINCT a.id) AS Applied,
            CONCAT(
              ROUND(
                (COUNT(DISTINCT CASE WHEN a.status = 'recruited' THEN a.id END) / COUNT(DISTINCT a.id)::numeric) * 100,
                2
              ),
              '%'
            ) AS Percentage
          FROM
            application_forms af
            JOIN application_choices a ON a.application_form_id = af.id
          WHERE
            af.recruitment_cycle_year = '2023'
          GROUP BY
            Age",
        ).to_a
      end
    end
  end
end

module ProviderInterface
  class DiversityDataByProvider
    attr_reader :provider

    def initialize(provider:)
      @provider = provider
    end

    def completed_e_and_d_survey_count
      ApplicationForm.where.not(equality_and_diversity: nil).where(recruitment_cycle_year: 2023).count
    end

    def total_submitted_applications
      ApplicationForm.where(recruitment_cycle_year: 2023).where.not(submitted_at: nil).count
    end

    def sex_data
      application_form_data = application_form_query.group_by do |application_form|
        [status_bucket_for(application_form), application_form.equality_and_diversity['sex']]
      end.transform_values(&:count)

      Hesa::Sex.all(RecruitmentCycle.current_year).map do |sex|
        {
          header: sex.type.capitalize,
          values: [
            application_form_data[[:applied, sex.type]] || 0,
            application_form_data[[:offer, sex.type]] || 0,
            application_form_data[[:recruited, sex.type]] || 0
          ],
        }
      end
    end

    def disability_data
      application_form_data = application_form_query.group_by do |application_form|
        [status_bucket_for(application_form), application_form.equality_and_diversity['disabilities']]
      end.transform_values(&:count)

      Hesa::Disability::HESA_CONVERSION.keys.map do |disability|
        {
          header: disability,
          values: [
            (application_form_data.select { |k, v| k[0] == :applied && k[1].include?(disability) }.values.sum || 0),
            (application_form_data.select { |k, v| k[0] == :offer && k[1].include?(disability) }.values.sum || 0),
            (application_form_data.select { |k, v| k[0] == :recruited && k[1].include?(disability) }.values.sum || 0),
          ],
        }
      end
    end

    def ethnicity_data
      application_form_data = application_form_query.group_by do |application_form|
        [status_bucket_for(application_form), application_form.equality_and_diversity['ethnic_group']]
      end.transform_values(&:count)

      EthnicGroup.all.map do |ethnicity|
        {
          header: ethnicity,
          values: [
            application_form_data[[:applied, ethnicity]] || 0,
            application_form_data[[:offer, ethnicity]] || 0,
            application_form_data[[:recruited, ethnicity]] || 0
          ],
        }
      end
    end

    def age_data
      age_data_query.map do |data|
        {
          header: data['age'],
          values: [
            data['applied'],
            data['offered'],
            data['recruited'], 
            data['percentage']
          ],
        }
      end
    end

    def status_bucket_for(application_form)
      if application_form.statuses.include?('recruited')
        :recruited
      elsif application_form.statuses.any? { |status| ApplicationStateChange::OFFERED_STATES.include?(status.to_sym) }
        :offer
      else
        :applied
      end
    end

    def application_form_query
      ApplicationForm
        .joins(:application_choices)
        .where(recruitment_cycle_year: '2023')
        .where('application_choices.provider_ids @> ARRAY[?]::bigint[]', provider)
        .group('application_forms.id')
        .select('application_forms.id', 'application_forms.equality_and_diversity', 'ARRAY_AGG(application_choices.status) AS statuses')
    end

    def age_data_query
      ApplicationForm.joins(:application_choices)
        .where(recruitment_cycle_year: '2023')
        .where('application_choices.provider_ids @> ARRAY[?]::bigint[]', provider)
        .select("CASE
              WHEN date_part('year', age(now(), date_of_birth)) BETWEEN 18 AND 24 THEN '18 to 24'
              WHEN date_part('year', age(now(), date_of_birth)) BETWEEN 25 AND 34 THEN '25 to 34'
              WHEN date_part('year', age(now(), date_of_birth)) BETWEEN 35 AND 44 THEN '35 to 44'
              WHEN date_part('year', age(now(), date_of_birth)) BETWEEN 45 AND 54 THEN '45 to 54'
              WHEN date_part('year', age(now(), date_of_birth)) BETWEEN 55 AND 64 THEN '55 to 64'
              WHEN date_part('year', age(now(), date_of_birth)) >= 65 THEN '65 and over'
            END AS Age,
            COUNT(DISTINCT CASE WHEN application_choices.status = 'offer' THEN application_choices.id END) AS Offered,
            COUNT(DISTINCT CASE WHEN application_choices.status = 'recruited' THEN application_choices.id END) AS Recruited,
            COUNT(DISTINCT application_choices.id) AS Applied,
            CONCAT(
              ROUND(
                (COUNT(DISTINCT CASE WHEN application_choices.status = 'recruited' THEN application_choices.id END) / COUNT(DISTINCT application_choices.id)::numeric) * 100,
                2
              ),
              '%'
            ) AS Percentage")
        .group('Age')
    end
  end
end

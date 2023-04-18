module ProviderInterface
  class DiversityDataByProvider
    AGE_GROUPS = [
      "18 to 24",
      "25 to 34",
      "35 to 44",
      "45 to 54",
      "55 to 64",
      "65 or over"
    ].freeze

    attr_reader :provider

    def initialize(provider:)
      @provider = provider
    end

    def completed_e_and_d_survey_count
      ApplicationForm
        .joins(:application_choices)
        .where('application_choices.provider_ids @> ARRAY[?]::bigint[]', provider)
        .where.not(equality_and_diversity: nil)
        .where(recruitment_cycle_year: 2023)
        .count
    end

    def total_submitted_applications
      ApplicationForm
        .joins(:application_choices)
        .where('application_choices.provider_ids @> ARRAY[?]::bigint[]', provider)
        .where(recruitment_cycle_year: 2023)
        .where.not(submitted_at: nil)
        .count
    end

    def sex_data
      application_form_data = counted_groups_by('sex')

      Hesa::Sex.all(RecruitmentCycle.current_year).map do |sex|
        {
          header: sex.type.capitalize,
          values: [
            application_form_data[[:applied, sex.type]] || 0,
            application_form_data[[:offer, sex.type]] || 0,
            application_form_data[[:recruited, sex.type]] || 0,
            calculate_percentage(application_form_data[[:applied, sex.type]], application_form_data[[:recruited, sex.type]])
          ],
        }
      end
    end

    def disability_data
      application_form_data = counted_groups_by('disabilities')

      Hesa::Disability::HESA_CONVERSION.keys.map do |disability|
        {
          header: disability,
          values: [
            (application_form_data.select { |k, _| k[0] == :applied && k[1].include?(disability) }.values.sum || 0),
            (application_form_data.select { |k, _| k[0] == :offer && k[1].include?(disability) }.values.sum || 0),
            (application_form_data.select { |k, _| k[0] == :recruited && k[1].include?(disability) }.values.sum || 0),
            calculate_percentage(application_form_data.select { |k, _| k[0] == :applied && k[1].include?(disability) }.values.sum, application_form_data.select { |k, _| k[0] == :recruited && k[1].include?(disability) }.values.sum)
          ],
        }
      end
    end

    def ethnicity_data
      application_form_data = counted_groups_by('ethnic_group')

      EthnicGroup.all.map do |ethnicity|
        {
          header: ethnicity,
          values: [
            application_form_data[[:applied, ethnicity]] || 0,
            application_form_data[[:offer, ethnicity]] || 0,
            application_form_data[[:recruited, ethnicity]] || 0,
            calculate_percentage(application_form_data[[:applied, ethnicity]], application_form_data[[:recruited, ethnicity]])
          ],
        }
      end
    end

    def age_data
      application_form_data = counted_groups_by('age')

      AGE_GROUPS.map do |age_group|
        {
          header: age_group,
          values: [
            application_form_data[[:applied, age_group]] || 0,
            application_form_data[[:offer, age_group]] || 0,
            application_form_data[[:recruited, age_group]] || 0,
            calculate_percentage(application_form_data[[:applied, age_group]], application_form_data[[:recruited, age_group]])

          ],
        }
      end
    end

  private

  def calculate_percentage(applied, recruited)
    applied.blank? || applied.zero? ? '-' : "#{(((recruited || 0) / applied.to_f) * 100).round}%"
  end

    def counted_groups_by(attribute)
      application_form_query.group_by do |application_form|
        if attribute == 'age'
          [status_bucket_for(application_form), age_group_for(application_form.date_of_birth)]
        else
          [status_bucket_for(application_form), application_form.equality_and_diversity[attribute]]
        end
      end.transform_values(&:count)
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

    def age_group_for(date_of_birth)
      age = ((Time.zone.now - date_of_birth.to_time) / 1.year.seconds).floor
      case age
      when 18..24 then '18 to 24'
      when 25..34 then '25 to 34'
      when 35..44 then '35 to 44'
      when 45..54 then '45 to 54'
      when 55..64 then '55 to 64'
      else '65 or over'
      end
    end

    def application_form_query
      ApplicationForm
        .joins(:application_choices)
        .where(recruitment_cycle_year: '2023')
        .where('application_choices.provider_ids @> ARRAY[?]::bigint[]', provider)
        .group('application_forms.id')
        .select('application_forms.id', 'application_forms.equality_and_diversity', 'application_forms.date_of_birth', 'ARRAY_AGG(application_choices.status) AS statuses')
    end
  end
end

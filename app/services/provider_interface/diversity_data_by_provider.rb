module ProviderInterface
  class DiversityDataByProvider
    AGE_GROUPS = [
      '18 to 24',
      '25 to 34',
      '35 to 44',
      '45 to 54',
      '55 to 64',
      '65 or over',
    ].freeze

    REPORT_HEADERS = [
      'Applied',
      'Offered',
      'Recruited',
      'Percentage recruited',
    ].freeze

    attr_reader :provider, :recruitment_cycle_year

    def initialize(provider:, recruitment_cycle_year:)
      @provider = provider
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def total_submitted_applications
      ApplicationForm
        .joins(:application_choices)
        .where.not(application_choices: { sent_to_provider_at: nil })
        .where('application_choices.provider_ids @> ARRAY[?]::bigint[]', provider)
        .where(recruitment_cycle_year:)
        .count
    end

    def sex_data
      application_form_data = counted_groups_by('sex')

      sex_values = Hesa::Sex.all(recruitment_cycle_year).reject { |sex| %w[99 96].include?(sex.hesa_code) }
      sex_values << Hesa::Sex::SexStruct.new('00', 'Prefer not to say')

      sex_values.map do |sex|
        applied, offer, recruited = counts_for(application_form_data, sex.type)
        {
          header: sex.type.capitalize,
          values: [
            applied,
            offer,
            recruited,
            calculate_percentage(applied, recruited),
          ],
        }
      end
    end

    def candidates_with_disability_data
      with_disabilities = disability_info(counted_grouped_disabilities)

      without_disabilities = Hesa::Disability::NON_DISABILITY_KEYS.map { |disability| disability_info(counted_grouped_disabilities, disability) }

      without_disabilities.unshift(with_disabilities)
    end

    def disability_data
      Hesa::Disability.disability_keys
        .map { |disability| disability_info(counted_grouped_disabilities, disability) }
    end

    def ethnicity_data
      application_form_data = counted_groups_by('ethnic_group')

      EthnicGroup.all.push('Prefer not to say').map do |ethnicity|
        applied, offer, recruited = counts_for(application_form_data, ethnicity)
        {
          header: ethnicity,
          values: [
            applied,
            offer,
            recruited,
            calculate_percentage(applied, recruited),
          ],
        }
      end
    end

    def age_data
      application_form_data = counted_groups_by('age')

      AGE_GROUPS.map do |age_group|
        applied, offer, recruited = counts_for(application_form_data, age_group)
        {
          header: age_group,
          values: [
            applied,
            offer,
            recruited,
            calculate_percentage(applied, recruited),
          ],
        }
      end
    end

  private

    def counts_for(data, group)
      [
        applied_count_for(data, group),
        offer_count_for(data, group),
        recruited_count_for(data, group),
      ]
    end

    def applied_count_for(data, group)
      count_for(data, :applied, group) +
        count_for(data, :offer, group) +
        count_for(data, :recruited, group)
    end

    def offer_count_for(data, group)
      count_for(data, :offer, group) +
        count_for(data, :recruited, group)
    end

    def recruited_count_for(data, group)
      count_for(data, :recruited, group)
    end

    def count_for(data, bucket, group)
      data[[bucket, group]] || 0
    end

    def counted_grouped_disabilities
      @counted_grouped_disabilities ||= counted_groups_by('disabilities')
    end

    def disability_info(data, disability = nil)
      applied, offer, recruited = disability_counts_for(data, disability)
      {
        header: disability.nil? ? 'At least one disability or health condition declared' : disability,
        values: [
          applied,
          offer,
          recruited,
          calculate_percentage(applied, recruited),
        ],
      }
    end

    def disability_counts_for(data, group)
      [
        applied_disability_count_for(data, group),
        offer_disability_count_for(data, group),
        recruited_disability_count_for(data, group),
      ]
    end

    def applied_disability_count_for(data, group)
      count_for_disabilities_and_status(data, :applied, group) +
        count_for_disabilities_and_status(data, :offer, group) +
        count_for_disabilities_and_status(data, :recruited, group)
    end

    def offer_disability_count_for(data, group)
      count_for_disabilities_and_status(data, :offer, group) +
        count_for_disabilities_and_status(data, :recruited, group)
    end

    def recruited_disability_count_for(data, group)
      count_for_disabilities_and_status(data, :recruited, group)
    end

    def count_for_disabilities_and_status(data, status, disability = nil)
      data.select do |selected_disabilities|
        application_status, selected_disabilities = selected_disabilities
        selected_disabilities ||= []
        any_disabilities = (selected_disabilities - Hesa::Disability::NON_DISABILITY_KEYS).any?
        application_status == status && (disability.nil? ? any_disabilities : selected_disabilities.include?(disability))
      end.values.sum
    end

    def calculate_percentage(applied, recruited)
      applied.blank? || applied.zero? ? '-' : "#{(((recruited || 0) / applied.to_f) * 100).round}%"
    end

    def counted_groups_by(attribute)
      application_form_query.group_by do |application_form|
        if attribute == 'age'
          [status_bucket_for(application_form), age_group_for(application_form.date_of_birth)]
        else
          [status_bucket_for(application_form), Hash(application_form.equality_and_diversity)[attribute]]
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
      return if date_of_birth.nil?

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
        .where.not(application_choices: { sent_to_provider_at: nil })
        .where(recruitment_cycle_year:)
        .where('application_choices.provider_ids @> ARRAY[?]::bigint[]', provider)
        .group('application_forms.id')
        .select('application_forms.id', 'application_forms.equality_and_diversity', 'application_forms.date_of_birth', 'ARRAY_AGG(application_choices.status) AS statuses')
    end
  end
end

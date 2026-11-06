module SupportInterface
  class DuplicateMatchesFilter
    include FilterParamsHelper

    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = compact_params(params)
    end

    def filters
      [
        {
          type: :search,
          heading: 'Name',
          value: applied_filters[:name],
          name: 'name',
        },
        {
          type: :search,
          heading: 'Email',
          value: applied_filters[:email],
          name: 'email',
        },
        {
          type: :search,
          heading: 'Postcode',
          value: applied_filters[:postcode],
          name: 'postcode',
        },
        {
          type: :date,
          heading: 'Date of birth',
          value: {
            '3i' => applied_filters['date_of_birth(3i)'],
            '2i' => applied_filters['date_of_birth(2i)'],
            '1i' => applied_filters['date_of_birth(1i)'],
          },
          name: 'date_of_birth',
        },
      ]
    end

    def filter_records(duplicate_matches)
      duplicate_matches = duplicate_matches.joins(candidates: :application_forms)
      if applied_filters[:name].present?
        duplicate_matches = duplicate_matches.where(
          "CONCAT(application_forms.first_name, ' ', application_forms.last_name) ILIKE ?", "%#{applied_filters[:name]}%"
        )
      end
      duplicate_matches = duplicate_matches.where('candidates.email_address ILIKE ?', "%#{applied_filters[:email]}%") if applied_filters[:email].present?
      duplicate_matches = duplicate_matches.where('fraud_matches.postcode ILIKE ?', "%#{applied_filters[:postcode]}%") if applied_filters[:postcode].present?
      if applied_filters['date_of_birth(3i)'].present? && applied_filters['date_of_birth(2i)'].present? &&
         applied_filters['date_of_birth(1i)'].present?
        if Date.valid_date?(applied_filters['date_of_birth(1i)'].to_i, applied_filters['date_of_birth(2i)'].to_i, applied_filters['date_of_birth(3i)'].to_i)
          date_of_birth = Date.new(
            applied_filters['date_of_birth(1i)'].to_i,
            applied_filters['date_of_birth(2i)'].to_i,
            applied_filters['date_of_birth(3i)'].to_i,
          )
          duplicate_matches = duplicate_matches.where(date_of_birth: date_of_birth)
        else
          duplicate_matches = duplicate_matches.none
        end
      end
      duplicate_matches.distinct
    end
  end
end

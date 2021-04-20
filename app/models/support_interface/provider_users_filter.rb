module SupportInterface
  class ProviderUsersFilter
    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = params
    end

    def filters
      [
        {
          type: :checkboxes,
          heading: 'Use of service',
          name: 'use_of_service',
          options: [
            {
              value: 'has_signed_in',
              label: 'Has signed in',
              checked: applied_filters[:use_of_service]&.include?('has_signed_in'),
            },
            {
              value: 'never_signed_in',
              label: 'Never signed in',
              checked: applied_filters[:use_of_service]&.include?('never_signed_in'),
            },

          ],
        },
        {
          type: :search,
          heading: 'Name, email or ID',
          value: applied_filters[:q],
          name: 'q',
        },
      ]
    end
  end
end

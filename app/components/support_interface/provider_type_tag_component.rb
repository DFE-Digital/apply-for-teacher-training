module SupportInterface
  class ProviderTypeTagComponent < ViewComponent::Base
    PROVIDER_TYPES = {
      'lead_school' => { text: 'School Direct', colour: 'green' },
      'scitt' => { text: 'SCITT', colour: 'yellow' },
      'university' => { text: 'HEI', colour: 'blue' },
    }.freeze

    def initialize(provider:)
      @provider_type = provider.provider_type
    end

    def render?
      @provider_type.present?
    end

    def text
      PROVIDER_TYPES.dig(@provider_type, :text)
    end

    def colour
      PROVIDER_TYPES.dig(@provider_type, :colour)
    end
  end
end

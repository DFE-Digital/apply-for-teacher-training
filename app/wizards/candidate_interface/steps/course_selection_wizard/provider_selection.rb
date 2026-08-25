module CandidateInterface
  module Steps
    class CourseSelectionWizard::ProviderSelection
      include DfE::Wizard::Step
      include FreeTextInputHelper

      attribute :provider_id, :string
      attribute :provider_id_raw

      validates :provider_id, presence: true
      validate :no_free_text_input

      alias_attribute :value, :provider_id
      alias_attribute :raw_input, :provider_id_raw
      alias_attribute :valid_options, :select_provider_options

      def self.permitted_params
        %i[provider_id provider_id_raw]
      end

      def select_provider_options
        @select_provider_options ||= available_providers.map do |provider|
          [provider.name_and_code, provider.id]
        end.unshift([nil, nil])
      end

      def no_free_text_input
        errors.add(:provider_id, :blank) if invalid_raw_data?
      end

      def available_providers
        @available_providers ||= GetAvailableProviders.call
      end
    end
  end
end

module CandidateInterface
  module CourseChoices
    class ProviderSelectionStep < DfE::Wizard::Step
      include FreeTextInputHelper

      attr_accessor :provider_id, :provider_id_raw, :course_id
      validates :provider_id, presence: true
      validate :no_free_text_input

      alias_attribute :value, :provider_id
      alias_attribute :raw_input, :provider_id_raw
      alias_attribute :valid_options, :select_provider_options

      def self.permitted_params
        %i[provider_id provider_id_raw course_id]
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

      def previous_step
        :do_you_know_the_course
      end

      def next_step
        :which_course_are_you_applying_to
      end

      def next_step_path_arguments
        { provider_id:, course_id: }.compact_blank
      end
    end
  end
end

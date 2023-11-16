module CandidateInterface
  module ContinuousApplications
    class ProviderSelectionStep < DfE::WizardStep
      attr_accessor :provider_id
      validates :provider_id, presence: true

      def self.permitted_params
        [:provider_id]
      end

      def provider_cache_key
        @provider_cache_key ||= "provider-list-#{Provider.maximum(:updated_at)}"
      end

      def available_providers
        GetAvailableProviders.call
      end

      def previous_step
        :do_you_know_the_course
      end

      def next_step
        :which_course_are_you_applying_to
      end

      def next_step_path_arguments
        { provider_id: }
      end
    end
  end
end

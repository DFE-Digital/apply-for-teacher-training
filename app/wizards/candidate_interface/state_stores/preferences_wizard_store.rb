module CandidateInterface
  module StateStores
    class PreferencesWizardStore
      include DfE::Wizard::StateStore

      attr_reader :current_application_id

      delegate :candidate, to: :current_application
      delegate :applied_only_to_salaried_courses?, to: :candidate

      def current_application
        ApplicationForm.find(self[:current_application_id])
      end

      def opt_in?
        pool_status == 'opt_in'
      end

      def training_locations_anywhere?
        training_locations == 'anywhere'
      end

      def training_locations_specific?
        training_locations == 'specific'
      end

      def only_salaried_courses_and_anywhere?
        applied_only_to_salaried_courses? && training_locations_anywhere?
      end

      def funding_type
        nil
      end
    end
  end
end


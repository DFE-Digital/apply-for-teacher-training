module CandidateInterface
  module StateStores
    class CourseSelectionWizardStore
      include DfE::Wizard::StateStore

      def know_the_course_to_apply?
        answer == 'yes'
      end

      def provider
        Provider.find(provider_id)
      end

      def completed?
        true
      end

      def reapplication_limit_reached?
        false
      end

      def duplicate_course?
        false
      end

      def course_closed?
        false
      end

      def course_unavailable?
        false
      end

      def multiple_study_modes?
        false
      end

      def multiple_schools?
        false
      end
    end
  end
end

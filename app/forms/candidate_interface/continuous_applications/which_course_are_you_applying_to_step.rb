module CandidateInterface
  module ContinuousApplications
    class WhichCourseAreYouApplyingToStep < DfE::WizardStep
      attr_accessor :provider_id, :course_id
      validates :provider_id, :course_id, presence: true

      def self.permitted_params
        %i[provider_id course_id]
      end

      def radio_available_courses
        ::CandidateInterface::PickCourseForm.new(provider_id:).radio_available_courses
      end

      def dropdown_available_courses
        ::CandidateInterface::PickCourseForm.new(provider_id:).dropdown_available_courses
      end

      def next_step
        # return :review if can_be_persisted?
        #
        # if currently_has_both_study_modes_available?
        #   :choose_study_mode
        # elsif :multiple_sites?
        #   :choose_site
        # end
      end
    end
  end
end

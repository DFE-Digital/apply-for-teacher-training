module CandidateInterface
  module Gcse
    module GradeControllerConcern
      extend ActiveSupport::Concern

      included do
        helper_method :autocomplete_grades?
      end

      def autocomplete_grades?
        @subject.in?(%w[maths english]) && @qualification_type == 'gcse'
      end

      def next_gcse_path
        if details_form.award_year.nil?
          candidate_interface_gcse_details_edit_year_path(subject: @subject)
        else
          candidate_interface_gcse_review_path(subject: @subject)
        end
      end

      def details_params
        params.require(:candidate_interface_gcse_qualification_details_form).permit(%i[grade award_year other_grade])
      end

      def details_form
        @details_form ||= GcseQualificationDetailsForm.build_from_qualification(
          current_application.qualification_in_subject(:gcse, @subject),
        )
      end

      def update_gcse_completed(value)
        attribute_to_update = "#{@subject}_gcse_completed"
        current_application.update!("#{attribute_to_update}": value)
      end
    end
  end
end

module CandidateInterface
  module Degrees
    class ReviewController < BaseController
      def show
        @application_form = current_application
        @section_complete_form = SectionCompleteForm.new(completed: current_application.degrees_completed)
      end

      def complete
        @application_form = current_application
        @section_complete_form = SectionCompleteForm.new(application_form_params)

        if @application_form.incomplete_degree_information? &&
           ActiveModel::Type::Boolean.new.cast(@section_complete_form.completed)
          flash[:warning] = 'You cannot mark this section complete with incomplete degree information.'
          redirect_to candidate_interface_degrees_review_path
        elsif @section_complete_form.save(current_application, :degrees_completed)
          redirect_to candidate_interface_application_form_path
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

    private

      def application_form_params
        strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
      end
    end
  end
end

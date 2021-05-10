module CandidateInterface
  module Degrees
    class CompletionStatusController < BaseController
      def new
        @completion_status_form = DegreeCompletionStatusForm.new
      end

      def create
        @completion_status_form = DegreeCompletionStatusForm.new(completion_status_params)
        if @completion_status_form.save(current_degree)
          redirect_to candidate_interface_degree_grade_path
        else
          track_validation_error(@completion_status_form)
          render :new
        end
      end

      def edit
        @completion_status_form = DegreeCompletionStatusForm.new(completion_status_params).assign_form_values(current_degree)
      end

      def update
        @completion_status_form = DegreeCompletionStatusForm.new(completion_status_params)

        if @completion_status_form.save(current_degree)
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@completion_status_form)
          render :edit
        end
      end

    private

      def completion_status_params
        params
          .fetch(:candidate_interface_degree_completion_status_form, {})
          .permit(:degree_completed)
      end
    end
  end
end

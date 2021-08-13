module CandidateInterface
  module Degrees
    class CompletionStatusController < BaseController
      def new
        set_previous_path
        @completion_status_form = DegreeCompletionStatusForm.new.assign_form_values(current_degree)
      end

      def create
        @completion_status_form = DegreeCompletionStatusForm.new(completion_status_params)
        if @completion_status_form.save(current_degree)
          redirect_to candidate_interface_degree_grade_path
        else
          set_previous_path
          track_validation_error(@completion_status_form)
          render :new
        end
      end

      def edit
        @completion_status_form = DegreeCompletionStatusForm.new(completion_status_params).assign_form_values(current_degree)
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)
      end

      def update
        @completion_status_form = DegreeCompletionStatusForm.new(completion_status_params)
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)

        if @completion_status_form.save(current_degree)
          redirect_to @return_to[:back_path]
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

      def set_previous_path
        @previous_path = if current_degree.international?
                           candidate_interface_degree_enic_path
                         else
                           candidate_interface_degree_institution_path
                         end
      end
    end
  end
end

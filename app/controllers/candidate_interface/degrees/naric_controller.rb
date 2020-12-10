module CandidateInterface
  module Degrees
    class NaricController < BaseController
      def new
        @degree_naric_form = DegreeNaricForm.new(degree: current_degree)
      end

      def create
        @degree_naric_form = DegreeNaricForm.new(naric_params)

        if @degree_naric_form.save
          redirect_to candidate_interface_degree_completion_status_path
        else
          track_validation_error(@degree_naric_form)
          render :new
        end
      end

      def edit
        @degree_naric_form = DegreeNaricForm.new(degree: current_degree).assign_form_values
      end

      def update
        @degree_naric_form = DegreeNaricForm.new(naric_params)
        if @degree_naric_form.save
          current_application.update!(degrees_completed: false)
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_naric_form)
          render :edit
        end
      end

    private

      def naric_params
        strip_whitespace params
          .require(:candidate_interface_degree_naric_form)
          .permit(:have_naric_reference, :naric_reference, :comparable_uk_degree)
          .merge(degree: current_degree)
      end
    end
  end
end

module CandidateInterface
  module Degrees
    class StartYearController < BaseController
      def new
        @degree_start_year_form = DegreeStartYearForm.new(degree: current_degree).assign_form_values
      end

      def create
        @degree_start_year_form = DegreeStartYearForm.new(degree_start_year_params)

        if @degree_start_year_form.save
          redirect_to candidate_interface_degree_award_year_path
        else
          track_validation_error(@degree_start_year_form)
          render :new
        end
      end

      def edit
        @degree_start_year_form = DegreeStartYearForm.new(degree: current_degree).assign_form_values
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)
      end

      def update
        @degree_start_year_form = DegreeStartYearForm.new(degree_start_year_params)
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)

        if @degree_start_year_form.save
          redirect_to @return_to[:back_path]
        else
          track_validation_error(@degree_start_year_form)
          render :edit
        end
      end

    private

      def degree_start_year_params
        strip_whitespace(
          params.require(:candidate_interface_degree_start_year_form).permit(:start_year),
        ).merge(degree: current_degree)
      end
    end
  end
end

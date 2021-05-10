module CandidateInterface
  module Degrees
    class YearController < BaseController
      def new
        @degree_year_form = DegreeYearForm.new(degree: current_degree)
      end

      def create
        @degree_year_form = DegreeYearForm.new(degree_year_params)

        if @degree_year_form.save
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_year_form)
          render :new
        end
      end

      def edit
        @degree_year_form = DegreeYearForm.new(degree: current_degree).assign_form_values
      end

      def update
        @degree_year_form = DegreeYearForm.new(degree_year_params)

        if @degree_year_form.save
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_year_form)
          render :edit
        end
      end

    private

      def degree_year_params
        strip_whitespace(
          params.require(:candidate_interface_degree_year_form).permit(:start_year, :award_year),
        ).merge(degree: current_degree)
      end
    end
  end
end

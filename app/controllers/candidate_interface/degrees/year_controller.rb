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
          render :new
        end
      end

      def edit
        @degree_year_form = DegreeYearForm.new(degree: current_degree).fill_form_values
      end

      def update
        @degree_year_form = DegreeYearForm.new(degree_year_params)

        if @degree_year_form.save
          current_application.update!(degrees_completed: false)
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_year_form)
          render :new
        end
      end

    private

      def degree_year_params
        params
          .require(:candidate_interface_degree_year_form)
          .permit(:start_year, :award_year)
          .transform_values(&:strip)
          .merge(degree: current_degree)
      end
    end
  end
end

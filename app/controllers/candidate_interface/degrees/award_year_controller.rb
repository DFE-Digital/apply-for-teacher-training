module CandidateInterface
  module Degrees
    class AwardYearController < BaseController
      def new
        @degree_award_year_form = DegreeAwardYearForm.new(degree: current_degree).assign_form_values
      end

      def create
        @degree_award_year_form = DegreeAwardYearForm.new(degree_award_year_params)

        if @degree_award_year_form.save
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_award_year_form)
          render :new
        end
      end

      def edit
        @degree_award_year_form = DegreeAwardYearForm.new(degree: current_degree).assign_form_values
      end

      def update
        @degree_award_year_form = DegreeAwardYearForm.new(degree_award_year_params)

        if @degree_award_year_form.save
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_award_year_form)
          render :edit
        end
      end

    private

      def degree_award_year_params
        strip_whitespace(
          params.require(:candidate_interface_degree_award_year_form).permit(:award_year),
        ).merge(degree: current_degree)
      end
    end
  end
end

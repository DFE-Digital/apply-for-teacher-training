module CandidateInterface
  module Degrees
    class EnicController < BaseController
      def new
        @degree_enic_form = DegreeEnicForm.new(degree: current_degree)
      end

      def create
        @degree_enic_form = DegreeEnicForm.new(enic_params)

        if @degree_enic_form.save
          redirect_to candidate_interface_degree_completion_status_path
        else
          track_validation_error(@degree_enic_form)
          render :new
        end
      end

      def edit
        @degree_enic_form = DegreeEnicForm.new(degree: current_degree).assign_form_values
      end

      def update
        @degree_enic_form = DegreeEnicForm.new(enic_params)
        if @degree_enic_form.save
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_enic_form)
          render :edit
        end
      end

    private

      def enic_params
        strip_whitespace params
          .require(:candidate_interface_degree_enic_form)
          .permit(:have_enic_reference, :enic_reference, :comparable_uk_degree)
          .merge(degree: current_degree)
      end
    end
  end
end

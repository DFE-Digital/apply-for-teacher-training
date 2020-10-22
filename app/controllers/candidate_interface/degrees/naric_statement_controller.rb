module CandidateInterface
  module Degrees
    class NaricStatementController < DegreesBaseController
      def new
        render_404 unless FeatureFlag.active?(:international_degrees)

        @degree_naric_statement_form = DegreeNaricStatementForm.new(degree: current_degree)
      end

      def create
        render_404 unless FeatureFlag.active?(:international_degrees)

        @degree_naric_statement_form = DegreeNaricStatementForm.new(naric_statement_params)

        if @degree_naric_statement_form.save
          redirect_to candidate_interface_degree_grade_path
        else
          render :new
        end
      end

      def edit
        render_404 unless FeatureFlag.active?(:international_degrees)

        @degree_naric_statement_form = DegreeNaricStatementForm.new(degree: current_degree).fill_form_values
      end

      def update
        render_404 unless FeatureFlag.active?(:international_degrees)

        @degree_naric_statement_form = DegreeNaricStatementForm.new(naric_statement_params)
        if @degree_naric_statement_form.save
          current_application.update!(degrees_completed: false)
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_naric_statement_form)
          render :edit
        end
      end

    private

      def naric_statement_params
        params
          .require(:candidate_interface_degree_naric_statement_form)
          .permit(:have_naric_reference, :naric_reference, :comparable_uk_degree)
          .merge(degree: current_degree)
      end
    end
  end
end

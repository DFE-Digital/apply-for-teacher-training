module CandidateInterface
  module Degrees
    class InstitutionController < BaseController
      before_action :set_institution_names, :set_countries

      def new
        @degree_institution_form = DegreeInstitutionForm.new(degree: current_degree).assign_form_values
      end

      def create
        @degree_institution_form = DegreeInstitutionForm.new(institution_params)

        if @degree_institution_form.save
          if @degree_institution_form.international?
            redirect_to candidate_interface_degree_enic_path
          else
            redirect_to candidate_interface_degree_completion_status_path
          end
        else
          track_validation_error(@degree_institution_form)
          render :new
        end
      end

      def edit
        @degree_institution_form = DegreeInstitutionForm.new(degree: current_degree).assign_form_values
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)
      end

      def update
        @degree_institution_form = DegreeInstitutionForm.new(institution_params)
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)

        if @degree_institution_form.save
          redirect_to @return_to[:back_path]
        else
          track_validation_error(@degree_institution_form)
          render :edit
        end
      end

    private

      def set_countries
        @countries = COUNTRIES
      end

      def set_institution_names
        @institutions = Hesa::Institution.names
      end

      def institution_params
        strip_whitespace params
          .require(:candidate_interface_degree_institution_form)
          .permit(:institution_name, :institution_country)
          .merge(degree: current_degree)
      end
    end
  end
end

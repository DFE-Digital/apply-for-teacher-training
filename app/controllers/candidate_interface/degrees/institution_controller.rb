module CandidateInterface
  module Degrees
    class InstitutionController < CandidateInterfaceController
      def new
        @degree_institution_form = DegreeInstitutionForm.new(degree: degree)
      end

      def create
        @degree_institution_form = DegreeInstitutionForm.new(institution_params)

        if @degree_institution_form.save
          redirect_to candidate_interface_degree_grade_path
        else
          render :new
        end
      end

    private

      def degree
        @degree ||= ApplicationQualification.find(params[:id])
      end

      def institution_params
        params
          .require(:candidate_interface_degree_institution_form)
          .permit(:institution_name)
          .merge(degree: degree)
      end
    end
  end
end

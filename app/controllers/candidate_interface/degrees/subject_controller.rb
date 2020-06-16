module CandidateInterface
  module Degrees
    class SubjectController < CandidateInterfaceController
      def new
        @degree_subject_form = DegreeSubjectForm.new(degree: degree)
      end

      def create
        @degree_subject_form = DegreeSubjectForm.new(subject_params)
        if @degree_subject_form.save
          redirect_to candidate_interface_degree_institution_path(degree)
        else
          render :new
        end
      end

    private

      def degree
        @degree ||= ApplicationQualification.find(params[:id])
      end

      def subject_params
        params
          .require(:candidate_interface_degree_subject_form)
          .permit(:subject)
          .merge(degree: degree)
      end
    end
  end
end

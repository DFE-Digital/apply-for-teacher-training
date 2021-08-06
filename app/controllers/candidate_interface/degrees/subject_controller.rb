module CandidateInterface
  module Degrees
    class SubjectController < BaseController
      before_action :set_subject_names

      def new
        @degree_subject_form = DegreeSubjectForm.new(degree: current_degree).assign_form_values
      end

      def create
        @degree_subject_form = DegreeSubjectForm.new(subject_params)
        if @degree_subject_form.save
          redirect_to candidate_interface_degree_institution_path(current_degree)
        else
          track_validation_error(@degree_subject_form)
          render :new
        end
      end

      def edit
        @degree_subject_form = DegreeSubjectForm.new(degree: current_degree).assign_form_values
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)
      end

      def update
        @degree_subject_form = DegreeSubjectForm.new(subject_params)
        @return_to = return_to_after_edit(default: candidate_interface_degrees_review_path)

        if @degree_subject_form.save
          redirect_to @return_to[:back_path]
        else
          track_validation_error(@degree_subject_form)
          render :edit
        end
      end

    private

      def set_subject_names
        @subjects = Hesa::Subject.names
      end

      def subject_params
        strip_whitespace params
          .require(:candidate_interface_degree_subject_form)
          .permit(:subject)
          .merge(degree: current_degree)
      end
    end
  end
end

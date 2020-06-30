module CandidateInterface
  module Degrees
    class GradeController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted
      before_action :set_main_grades

      def new
        @degree_grade_form = DegreeGradeForm.new(degree: degree)
      end

      def create
        @degree_grade_form = DegreeGradeForm.new(grade_params)

        if @degree_grade_form.save
          redirect_to candidate_interface_degree_year_path(degree)
        else
          render :new
        end
      end

      def edit
        @degree_grade_form = DegreeGradeForm.new(degree: degree).fill_form_values
      end

      def update
        @degree_grade_form = DegreeGradeForm.new(grade_params)

        if @degree_grade_form.save
          current_application.update!(degrees_completed: false)
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_grade_form)
          render :new
        end
      end

    private

      def degree
        @degree = ApplicationQualification.find(params[:id])
      end

      def set_main_grades
        @main_grades = Hesa::Grade.main.map(&:description)
      end

      def grade_params
        params
          .require(:candidate_interface_degree_grade_form)
          .permit(:grade, :other_grade, :predicted_grade)
          .transform_values(&:strip)
          .merge(degree: degree)
      end
    end
  end
end

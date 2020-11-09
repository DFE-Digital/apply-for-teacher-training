module CandidateInterface
  module Degrees
    class GradeController < BaseController
      before_action :set_main_grades
      before_action :set_other_grades
      before_action :set_international_main_grades

      def new
        @degree_grade_form = DegreeGradeForm.new(degree: current_degree)
      end

      def create
        @degree_grade_form = DegreeGradeForm.new(grade_params)

        if @degree_grade_form.save
          redirect_to candidate_interface_degree_year_path(current_degree)
        else
          render :new
        end
      end

      def edit
        @degree_grade_form = DegreeGradeForm.new(degree: current_degree).fill_form_values
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

      def set_main_grades
        @main_grades = Hesa::Grade.grouping_for(
          degree_type_code: current_degree.qualification_type_hesa_code,
        ).map(&:description)
      end

      def set_international_main_grades
        @international_main_grades = DegreeGradeForm::INTERNATIONAL_OPTIONS
      end

      def set_other_grades
        @other_grades = Hesa::Grade.other_grouping.map(&:description)
      end

      def grade_params
        params
          .require(:candidate_interface_degree_grade_form)
          .permit(:grade, :other_grade)
          .transform_values(&:strip)
          .merge(degree: current_degree)
      end
    end
  end
end

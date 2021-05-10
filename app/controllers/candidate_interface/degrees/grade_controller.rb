module CandidateInterface
  module Degrees
    class GradeController < BaseController
      before_action :set_main_grades
      before_action :set_other_grades
      before_action :set_international_main_grades
      before_action :set_page_title

      def new
        @degree_grade_form = DegreeGradeForm.new(degree: current_degree)
      end

      def create
        @degree_grade_form = DegreeGradeForm.new(grade_params)

        if @degree_grade_form.save
          redirect_to candidate_interface_degree_year_path(current_degree)
        else
          track_validation_error(@degree_grade_form)
          render :new
        end
      end

      def edit
        @degree_grade_form = DegreeGradeForm.new(degree: current_degree).assign_form_values
      end

      def update
        @degree_grade_form = DegreeGradeForm.new(grade_params)

        if @degree_grade_form.save
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_grade_form)
          render :edit
        end
      end

    private

      def set_main_grades
        @main_grades = Hesa::Grade.grouping_for(
          degree_type_code: current_degree.qualification_type_hesa_code,
        ).map(&:description)
      end

      def set_international_main_grades
        @international_main_grades = DegreeGradeForm::NEGATIVE_INTERNATIONAL_OPTIONS.map { |o| o[:ui_value] }
      end

      def set_other_grades
        @other_grades = Hesa::Grade.other_grouping.map(&:description)
      end

      def grade_params
        strip_whitespace params
          .require(:candidate_interface_degree_grade_form)
          .permit(:grade, :other_grade)
          .merge(degree: current_degree)
      end

      def set_page_title
        @page_title =
          begin
            if current_degree.international?
              current_degree.completed? ? t('page_titles.degree_grade_international') : t('page_titles.degree_grade_international_predicted')
            else
              current_degree.completed? ? t('page_titles.degree_grade') : t('page_titles.degree_grade_predicted')
            end
          end
      end
    end
  end
end

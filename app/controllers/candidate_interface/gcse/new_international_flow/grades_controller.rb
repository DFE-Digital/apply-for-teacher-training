module CandidateInterface
  class Gcse::NewInternationalFlow::GradesController < Gcse::NewInternationalFlow::BaseController
    def new
      @structured_grades_form = GcseInternationalStructuredGradesForm.build_from_qualification(current_qualification, structured_grades: @structured_grades)
      @list_of_grades = @structured_grades.any?
    end

    def edit
      @structured_grades_form = GcseInternationalStructuredGradesForm.build_from_qualification(current_qualification, structured_grades: @structured_grades)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
      @list_of_grades = @structured_grades.any?
    end

    def create
      @structured_grades_form = GcseInternationalStructuredGradesForm.new(structured_grade_params)
      @list_of_grades = @structured_grades.any?

      if @structured_grades_form.save(current_qualification)
        if passing_grade?
          redirect_to candidate_interface_gcse_new_international_flow_new_enic_path
        else
          redirect_to candidate_interface_gcse_new_international_flow_interruption_path
        end
      else
        track_validation_error(@structured_grades_form)
        render :new
      end
    end

    def update
      @structured_grades_form = GcseInternationalStructuredGradesForm.new(structured_grade_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
      @list_of_grades = @structured_grades.any?

      if @structured_grades_form.save(current_qualification)
        if passing_grade?
          redirect_to candidate_interface_gcse_new_international_flow_edit_enic_path(@subject, 'return-to': 'grade-edit')
        else
          redirect_to candidate_interface_gcse_new_international_flow_interruption_path(@subject, 'return-to': 'grade-edit')
        end
      else
        track_validation_error(@structured_grades_form)
        render :edit
      end
    end

  private

    def passing_grade?
      if @structured_grades_form.grade == 'other'
        @structured_grades_form.non_structured_grade.present?
      else
        @structured_grades_form.grade.in?(@grade_schemas.first.passing_grades)
      end
    end

    def structured_grade_params
      params
        .expect(candidate_interface_gcse_international_structured_grades_form: %i[grade non_structured_grade])
    end
  end
end

module CandidateInterface
  class Gcse::NewInternationalFlow::GradesController < Gcse::NewInternationalFlow::BaseController
    def new
      @structured_grades_form = GcseInternationalStructuredGradesForm.build_from_qualification(current_qualification,
                                                                                               structured_grades: @structured_grades,
                                                                                               percentage: @selected_grade_schema&.type == 'Percentage')
      @list_of_grades = @structured_grades.any?
    end

    def edit
      @structured_grades_form = GcseInternationalStructuredGradesForm.build_from_qualification(current_qualification,
                                                                                               structured_grades: @structured_grades,
                                                                                               percentage: @selected_grade_schema&.type == 'Percentage')
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
      @list_of_grades = @structured_grades.any?
    end

    def create
      @structured_grades_form = GcseInternationalStructuredGradesForm.new(structured_grade_params.merge(percentage: @selected_grade_schema&.type == 'Percentage'))
      @list_of_grades = @structured_grades.any?

      if @structured_grades_form.save(current_qualification)
        if failing_grade?
          redirect_to candidate_interface_gcse_new_international_flow_interruption_path
        else
          redirect_to candidate_interface_gcse_new_international_flow_new_enic_path
        end
      else
        track_validation_error(@structured_grades_form)
        render :new
      end
    end

    def update
      @structured_grades_form = GcseInternationalStructuredGradesForm.new(structured_grade_params.merge(percentage: @selected_grade_schema&.type == 'Percentage'))
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
      @list_of_grades = @structured_grades.any?

      grade_changed = @structured_grades_form.resolved_grade != current_qualification.grade

      if @structured_grades_form.save(current_qualification)
        if !grade_changed
          redirect_to @return_to[:back_path]
        elsif grade_changed && failing_grade?
          redirect_to candidate_interface_gcse_new_international_flow_interruption_path
        else
          redirect_to candidate_interface_gcse_new_international_flow_edit_enic_path
        end
      else
        track_validation_error(@structured_grades_form)
        render :edit
      end
    end

  private

    def failing_grade?
      InspectInternationalGcseGrade.new(current_qualification).failing?
    end

    def structured_grade_params
      params
        .expect(candidate_interface_gcse_international_structured_grades_form: %i[grade non_structured_grade])
    end
  end
end

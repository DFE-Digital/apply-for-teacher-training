module CandidateInterface
  class Gcse::NewInternationalFlow::GradesController < Gcse::NewInternationalFlow::BaseController
    def new
      @structured_grades_form = GcseInternationalStructuredGradesForm.build_from_qualification(current_qualification,
                                                                                               structured_grades: @structured_grades,
                                                                                               percentage: selected_grade_schema_percentage?)
      @list_of_grades = @structured_grades.any?
      @percentage = selected_grade_schema_percentage?
      @back_path = new_flow_back_path
    end

    def edit
      @structured_grades_form = GcseInternationalStructuredGradesForm.build_from_qualification(current_qualification,
                                                                                               structured_grades: @structured_grades,
                                                                                               percentage: selected_grade_schema_percentage?)
      @list_of_grades = @structured_grades.any?
      @percentage = selected_grade_schema_percentage?
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
      @edit_back_path = edit_flow_back_path
    end

    def create
      @structured_grades_form = GcseInternationalStructuredGradesForm.new(structured_grade_params.merge(percentage: selected_grade_schema_percentage?))
      @percentage = selected_grade_schema_percentage?
      @list_of_grades = @structured_grades.any?

      if @structured_grades_form.save(current_qualification)
        if likely_below_level_four?
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
      @structured_grades_form = GcseInternationalStructuredGradesForm.new(structured_grade_params.merge(percentage: selected_grade_schema_percentage?))
      @percentage = selected_grade_schema_percentage?
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
      @list_of_grades = @structured_grades.any?

      grade_changed = @structured_grades_form.resolved_grade != current_qualification.grade

      if @structured_grades_form.save(current_qualification)
        if !grade_changed
          redirect_to @return_to[:back_path]
        elsif grade_changed && likely_below_level_four?
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

    def new_flow_back_path
      requires_grade_schema_selection? ? candidate_interface_gcse_new_international_flow_new_grade_schemas_path : candidate_interface_gcse_new_international_flow_new_qualifications_path
    end

    def edit_flow_back_path
      params['return-to'] == 'schema-type' ? candidate_interface_gcse_new_international_flow_edit_grade_schemas_path(@subject) : candidate_interface_gcse_review_path(@subject)
    end

    def likely_below_level_four?
      InspectInternationalGcseGrade.new(current_qualification).likely_below?
    end

    def structured_grade_params
      params
        .expect(candidate_interface_gcse_international_structured_grades_form: %i[grade non_structured_grade])
    end
  end
end

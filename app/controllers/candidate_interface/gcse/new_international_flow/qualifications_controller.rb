module CandidateInterface
  class Gcse::NewInternationalFlow::QualificationsController < Gcse::NewInternationalFlow::BaseController
    def new
      @equivalent_qualification_form = GcseEquivalentQualificationForm.build_from_qualification(current_qualification, equivalent_qualifications: @equivalent_qualifications.map(&:name) || [])
      @list_of_qualifications = @equivalent_qualifications&.any?
    end

    def edit
      @equivalent_qualification_form = GcseEquivalentQualificationForm.build_from_qualification(current_qualification, equivalent_qualifications: @equivalent_qualifications&.map(&:name) || [])
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
      @list_of_qualifications = @equivalent_qualifications&.any?
    end

    def create
      @equivalent_qualification_form = GcseEquivalentQualificationForm.new(equivalent_qualification_params)
      @list_of_qualifications = @equivalent_qualifications&.any?

      if @equivalent_qualification_form.save(current_qualification)
        redirect_to next_new_path_for_selected_qualification
      else
        track_validation_error(@equivalent_qualification_form)
        render :new
      end
    end

    def update
      @equivalent_qualification_form = GcseEquivalentQualificationForm.new(equivalent_qualification_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
      @list_of_qualifications = @equivalent_qualifications&.any?

      qualification_changed = @equivalent_qualification_form.resolved_qualification != current_qualification.non_uk_qualification_type

      if @equivalent_qualification_form.save(current_qualification)
        if qualification_changed
          redirect_to next_edit_path_for_selected_qualification
        else
          redirect_to @return_to[:back_path]
        end
      else
        track_validation_error(@equivalent_qualification_form)
        render :edit
      end
    end

  private

    def next_new_path_for_selected_qualification
      if multiple_grade_schemas_for_selected_qualification? || percentage_grade_schema_for_selected_qualification?
        candidate_interface_gcse_new_international_flow_new_grade_schemas_path(@subject)
      else
        candidate_interface_gcse_new_international_flow_new_grades_path(@subject)
      end
    end

    def next_edit_path_for_selected_qualification
      if multiple_grade_schemas_for_selected_qualification? || percentage_grade_schema_for_selected_qualification?
        candidate_interface_gcse_new_international_flow_edit_grade_schemas_path(@subject)
      else
        candidate_interface_gcse_new_international_flow_edit_grades_path(@subject)
      end
    end

    def multiple_grade_schemas_for_selected_qualification?
      selected_qualification_grade_schemas.many?
    end

    def percentage_grade_schema_for_selected_qualification?
      selected_qualification_grade_schemas.any? do |schema|
        schema.description == 'Percentage'
      end
    end

    def selected_qualification_grade_schemas
      selected_equivalent_qualification_for_current_selection&.grade_schemas || []
    end

    def selected_equivalent_qualification_for_current_selection
      finder.equivalent_qualifications.find do |qualification|
        qualification.name == current_qualification.non_uk_qualification_type
      end
    end

    def equivalent_qualification_params
      params
        .expect(candidate_interface_gcse_equivalent_qualification_form: %i[qualification non_structured_qualification])
    end
  end
end

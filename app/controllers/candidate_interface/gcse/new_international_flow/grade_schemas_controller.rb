module CandidateInterface
  class Gcse::NewInternationalFlow::GradeSchemasController < Gcse::NewInternationalFlow::BaseController
    def new
      @grade_schemas_form = GcseInternationalGradeSchemasForm.build_from_qualification(current_qualification)
    end

    def edit
      @grade_schemas_form = GcseInternationalGradeSchemasForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
    end

    def create
      @grade_schemas_form = GcseInternationalGradeSchemasForm.new(grade_schema_params)

      if @grade_schemas_form.save(current_qualification)
        redirect_to candidate_interface_gcse_new_international_flow_new_grades_path
      else
        render :new
      end
    end

    def update
      @grade_schemas_form = GcseInternationalGradeSchemasForm.new(grade_schema_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))

      if @grade_schemas_form.save(current_qualification)
        redirect_to candidate_interface_gcse_new_international_flow_edit_grades_path
      else
        render :edit
      end
    end

  private

    def grade_schema_params
      params.expect(candidate_interface_gcse_international_grade_schemas_form: [:schema_id])
    end
  end
end

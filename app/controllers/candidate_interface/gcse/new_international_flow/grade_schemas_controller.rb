module CandidateInterface
  class Gcse::NewInternationalFlow::GradeSchemasController < Gcse::NewInternationalFlow::BaseController
    def new
      @grade_schemas_form = GcseInternationalGradeSchemasForm.new
    end

    def edit
      @grade_schemas_form = GcseInternationalGradeSchemasForm.new
    end

    def create
      @grade_schemas_form = GcseInternationalGradeSchemasForm.new(grade_schema_params)

      if @grade_schemas_form.save(current_qualification)
        redirect_to candidate_interface_gcse_new_international_flow_new_grades_path
      else
        render :new
      end
    end

    def update; end

  private

    def grade_schema_params
      params.expect(candidate_interface_gcse_international_grade_schemas_form: [:schema])
    end
  end
end

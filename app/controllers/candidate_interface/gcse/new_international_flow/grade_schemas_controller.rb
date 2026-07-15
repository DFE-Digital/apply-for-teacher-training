module CandidateInterface
  class Gcse::NewInternationalFlow::GradeSchemasController < Gcse::NewInternationalFlow::BaseController
    def new
      @grade_schemas_form = GcseInternationalGradeSchemasForm.new
    end

    def edit
      @grade_schemas_form = GcseInternationalGradeSchemasForm.new
    end

    def create; end

    def update; end
  end
end

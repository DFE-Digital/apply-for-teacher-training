module CandidateInterface
  class Gcse::NewInternationalFlow::GradesController < Gcse::NewInternationalFlow::BaseController
    before_action :set_structured_grades

    def new
      @structured_grades_form = GcseInternationalStructuredGradesForm.build_from_qualification(current_qualification)
      @list_of_grades = @structured_grades.any?
    end

    def edit
      @structured_grades_form = GcseInternationalStructuredGradesForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
    end

    def create
      @structured_grades_form = GcseInternationalStructuredGradesForm.new(structured_grade_params)

      if @structured_grades_form.save(current_qualification)
        if passing_grade?
          # TODO: fix back paths for enic flow
          redirect_to candidate_interface_gcse_details_new_enic_path
        else
          redirect_to candidate_interface_gcse_new_international_flow_interruption_path
        end
      else
        track_validation_error(@equivalent_qualification_form)
        render :new
      end
    end

    def update
      @structured_grades_form = GcseInternationalStructuredGradesForm.new(structured_grade_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)

      if @structured_grades_form.save(current_qualification)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@equivalent_qualification_form)
        render :edit
      end
    end

  private

    def set_structured_grades
      # post-MVP we will map through the available schemas if there is more than one and present them for selection in an intermediary step
      # We can then use that value to present the relevant structured grades
      @structured_grades ||=
        if @selected_equivalent_qualification.blank?
          []
        else
          @grade_schemas.first.passing_grades + @grade_schemas.first.failing_grades
        end
    end

    def passing_grade?
      return true if @structured_grades_form.non_structured_grade.present?

      @structured_grades_form.grade.in?(@grade_schemas.first.passing_grades)
    end

    def structured_grade_params
      params
        .expect(candidate_interface_gcse_international_structured_grades_form: %i[grade non_structured_grade])
    end
  end
end

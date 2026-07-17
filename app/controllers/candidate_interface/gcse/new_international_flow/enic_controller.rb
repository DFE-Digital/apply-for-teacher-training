module CandidateInterface
  class Gcse::NewInternationalFlow::EnicController < Gcse::NewInternationalFlow::BaseController
    before_action :set_back_path, :set_edit_back_path

    def new
      @enic_form = GcseEnicSelectionForm.build_from_qualification(current_qualification)
    end

    def edit
      @enic_form = GcseEnicSelectionForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
    end

    def create
      @enic_form = GcseEnicSelectionForm.new(enic_params)

      if @enic_form.save(current_qualification)
        handle_redirection
      else
        track_validation_error(@enic_form)
        render :new
      end
    end

    def update
      @enic_form = GcseEnicSelectionForm.new(enic_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))

      if @enic_form.save(current_qualification)
        if enic_params[:enic_reason] == 'obtained'
          redirect_to edit_international_flow_statement_comparability_path(@subject)
        elsif current_qualification.award_year.nil?
          redirect_to candidate_interface_gcse_new_international_flow_edit_year_path(@subject)
        else
          redirect_to @return_to[:back_path]
        end
      else
        track_validation_error(@enic_form)
        render :edit
      end
    end

  private

    def handle_redirection
      if enic_params[:enic_reason] == 'obtained'
        redirect_to new_international_flow_statement_comparability_path(@subject)
      else
        redirect_to candidate_interface_gcse_new_international_flow_new_year_path(@subject)
      end
    end

    def set_back_path
      @back_path ||=
        if @grade_schemas.present? && current_qualification.grade.in?(@structured_grades)
          && current_qualification.grade.in?(@selected_grade_schema.likely_below_level_four)
          candidate_interface_gcse_new_international_flow_interruption_path(@subject)
        elsif params['return-to'] == 'schema-type'
          candidate_interface_gcse_new_international_flow_new_grade_schemas_path
        else
          candidate_interface_gcse_new_international_flow_new_grades_path(@subject)
        end
    end

    def set_edit_back_path
      @edit_back_path ||=
        if params['return-to'] == 'application-review'
          candidate_interface_gcse_review_path(@subject)
        elsif params['return-to'] == 'schema-type'
          candidate_interface_gcse_new_international_flow_edit_grade_schemas_path
        elsif @grade_schemas.present? && current_qualification.grade.in?(@structured_grades)
          && current_qualification.grade.in?(@selected_grade_schema.likely_below_level_four)
          candidate_interface_gcse_new_international_flow_interruption_path(@subject, 'return-to': 'application-review')
        else
          candidate_interface_gcse_new_international_flow_edit_grades_path
        end
    end

    def enic_params
      form_params = params[:candidate_interface_gcse_enic_selection_form]
      return {} unless form_params

      strip_whitespace(form_params).permit(:enic_reason)
    end
  end
end

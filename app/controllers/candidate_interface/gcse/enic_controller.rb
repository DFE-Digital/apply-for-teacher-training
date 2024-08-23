module CandidateInterface
  class Gcse::EnicController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern
    include GcseStatementComparabilityPathHelper

    def new
      @enic_form = GcseEnicSelectionForm.build_from_qualification(current_qualification)
    end

    def edit
      @enic_form = GcseEnicSelectionForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
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
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)

      if @enic_form.save(current_qualification)
        if enic_params[:enic_reason] == 'obtained'
          redirect_to x_gcse_edit_statement_comparability_path(subject_param)
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
        redirect_to x_gcse_new_statement_comparability_path(subject_param)
      else
        redirect_to resolve_gcse_edit_path(subject_param)
      end
    end

    def enic_params
      form_params = params[:candidate_interface_gcse_enic_selection_form]
      return {} unless form_params

      strip_whitespace(form_params).permit(:enic_reason)
    end
  end
end

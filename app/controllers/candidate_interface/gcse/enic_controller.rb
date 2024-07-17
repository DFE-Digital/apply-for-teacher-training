module CandidateInterface
  class Gcse::EnicController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern
    include Gcse::ResolveGcseStatementComparibilityPathConcern

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
        if enic_params[:have_enic_reference] == t('gcse_edit_enic.yes_enic')
          redirect_to resolve_gcse_edit_statement_comparibility_path(subject_param)
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
      case enic_params[:have_enic_reference]
      when t('gcse_edit_enic.yes_enic')
        redirect_to resolve_gcse_statement_comparibility_path(subject_param)
      when t('gcse_edit_enic.waiting_for_enic'),
           t('gcse_edit_enic.future_enic'),
           t('gcse_edit_enic.dont_want_enic')
        redirect_to resolve_gcse_edit_path(subject_param)
      end
    end

    def enic_params
      form_params = params[:candidate_interface_gcse_enic_selection_form]
      return {} unless form_params

      strip_whitespace(form_params).permit(:have_enic_reference)
    end
  end
end

module CandidateInterface
  class Gcse::NotCompletedQualificationController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern

    def new
      @gcse_not_completed_form = GcseNotCompletedForm.build_from_qualification(current_qualification)
    end

    def create
      @gcse_not_completed_form = GcseNotCompletedForm.new(qualification_not_completed_params)

      if @gcse_not_completed_form.save(current_qualification)
        if params[:candidate_interface_gcse_not_completed_form][:choice] == 'no'
          redirect_to candidate_interface_gcse_missing_path
        else
          redirect_to candidate_interface_gcse_review_path
        end
      else
        track_validation_error(@gcse_not_completed_form)
        render :new
      end
    end

    def edit
      @gcse_not_completed_form = GcseNotCompletedForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
    end

    def update
      @gcse_not_completed_form = GcseNotCompletedForm.new(qualification_not_completed_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)

      if @gcse_not_completed_form.save(current_qualification)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@gcse_not_completed_form)
        render :edit
      end
    end

  private

    def qualification_not_completed_params
      strip_whitespace params
        .require(:candidate_interface_gcse_not_completed_form)
        .permit(:not_completed_explanation, :choice)
    end
  end
end

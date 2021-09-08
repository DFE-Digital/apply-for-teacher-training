module CandidateInterface
  class Gcse::MissingQualificationController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern

    def new
      @gcse_missing_form = GcseMissingForm.build_from_qualification(current_qualification)
    end

    def create
      @gcse_missing_form = GcseMissingForm.new(qualification_missing_params)

      if @gcse_missing_form.save(current_qualification)
        redirect_to candidate_interface_gcse_review_path
      else
        track_validation_error(@gcse_missing_form)
        render :new
      end
    end

    def edit
      @gcse_missing_form = GcseMissingForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
    end

    def update
      @gcse_missing_form = GcseMissingForm.new(qualification_missing_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)

      if @gcse_missing_form.save(current_qualification)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@gcse_missing_form)
        render :edit
      end
    end

  private

    def qualification_missing_params
      strip_whitespace params
        .require(:candidate_interface_gcse_missing_form)
        .permit(:missing_explanation)
    end
  end
end

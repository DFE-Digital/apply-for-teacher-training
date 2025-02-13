module CandidateInterface
  class Gcse::MissingQualificationController < Gcse::BaseController
    include AdviserStatus
    include Gcse::ResolveGcseEditPathConcern

    def new
      set_back_link
      @gcse_missing_form = GcseMissingForm.build_from_qualification(current_qualification)
    end

    def edit
      @gcse_missing_form = GcseMissingForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
    end

    def create
      @gcse_missing_form = GcseMissingForm.new(qualification_missing_params)
      @gcse_missing_form.subject = @subject
      if @gcse_missing_form.save(current_qualification)
        redirect_to candidate_interface_gcse_review_path
      else
        set_back_link
        track_validation_error(@gcse_missing_form)
        render :new
      end
    end

    def update
      @gcse_missing_form = GcseMissingForm.new(qualification_missing_params)
      @gcse_missing_form.subject = @subject
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
        .expect(candidate_interface_gcse_missing_form: [:missing_explanation])
    end

    def set_back_link
      @path = if current_qualification.qualification_type == 'missing'
                candidate_interface_gcse_not_yet_completed_path
              else
                candidate_interface_gcse_details_new_grade_explanation_path
              end
    end
  end
end

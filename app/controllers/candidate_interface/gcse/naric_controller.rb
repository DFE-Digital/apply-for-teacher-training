module CandidateInterface
  class Gcse::NaricController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern

    def edit
      @naric_form = build_naric_form
    end

    def update
      @naric_form = build_naric_form

      @naric_form.set_attributes(naric_params)

      if @naric_form.save(current_qualification)
        update_gcse_completed(false)

        redirect_to next_gcse_path
      else
        track_validation_error(@naric_form)
        render :edit
      end
    end

  private

    def build_naric_form
      GcseNaricForm.build_from_qualification(current_qualification)
    end

    def next_gcse_path
      if current_qualification.grade.nil?
        resolve_gcse_edit_path(subject_param)
      else
        candidate_interface_gcse_review_path
      end
    end

    def naric_params
      strip_whitespace params
        .require(:candidate_interface_gcse_naric_form)
        .permit(:have_naric_reference, :naric_reference, :comparable_uk_qualification)
    end
  end
end

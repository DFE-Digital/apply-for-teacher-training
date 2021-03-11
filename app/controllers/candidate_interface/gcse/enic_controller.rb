module CandidateInterface
  class Gcse::EnicController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern

    def edit
      @enic_form = build_enic_form
    end

    def update
      @enic_form = build_enic_form

      @enic_form.set_attributes(enic_params)

      if @enic_form.save(current_qualification)
        update_gcse_completed(false)

        redirect_to next_gcse_path
      else
        track_validation_error(@enic_form)
        render :edit
      end
    end

  private

    def build_enic_form
      GcseEnicForm.build_from_qualification(current_qualification)
    end

    def next_gcse_path
      if current_qualification.grade.nil?
        resolve_gcse_edit_path(subject_param)
      else
        candidate_interface_gcse_review_path
      end
    end

    def enic_params
      strip_whitespace params
        .require(:candidate_interface_gcse_enic_form)
        .permit(:have_enic_reference, :enic_reference, :comparable_uk_qualification)
    end
  end
end

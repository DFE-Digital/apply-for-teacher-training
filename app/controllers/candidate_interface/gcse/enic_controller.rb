module CandidateInterface
  class Gcse::EnicController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern

    def new
      @enic_form = GcseEnicForm.build_from_qualification(current_qualification)
    end

    def create
      @enic_form = GcseEnicForm.new(enic_params)

      if @enic_form.save(current_qualification)
        redirect_to resolve_gcse_edit_path(subject_param)
      else
        track_validation_error(@enic_form)
        render :new
      end
    end

    def edit
      @enic_form = GcseEnicForm.build_from_qualification(current_qualification)
    end

    def update
      @enic_form = GcseEnicForm.new(enic_params)

      if @enic_form.save(current_qualification)
        redirect_to candidate_interface_gcse_review_path
      else
        track_validation_error(@enic_form)
        render :edit
      end
    end

  private

    def enic_params
      strip_whitespace params
        .require(:candidate_interface_gcse_enic_form)
        .permit(:have_enic_reference, :enic_reference, :comparable_uk_qualification)
    end
  end
end

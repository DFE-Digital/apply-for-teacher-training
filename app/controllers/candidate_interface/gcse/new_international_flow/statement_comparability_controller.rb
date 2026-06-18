module CandidateInterface
  class Gcse::NewInternationalFlow::StatementComparabilityController < Gcse::NewInternationalFlow::BaseController
    include Gcse::ResolveGcseEditPathConcern

    def new
      @enic_form = GcseEnicForm.build_from_qualification(current_qualification)
    end

    def edit
      @enic_form = GcseEnicForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(subject_param))
    end

    def create
      @enic_form = GcseEnicForm.new(enic_params)

      if @enic_form.save(current_qualification)
        redirect_to candidate_interface_gcse_new_international_flow_new_year_path
      else
        track_validation_error(@enic_form)
        render :new
      end
    end

    def update
      @enic_form = GcseEnicForm.new(enic_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(subject_param))

      if @enic_form.save(current_qualification)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@enic_form)
        render :edit
      end
    end

  private

    def enic_params
      strip_whitespace params
        .expect(candidate_interface_gcse_enic_form: %i[enic_reference comparable_uk_qualification])
    end
  end
end

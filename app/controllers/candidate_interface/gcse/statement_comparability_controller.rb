module CandidateInterface
  class Gcse::StatementComparabilityController < Gcse::BaseController
    include Gcse::ResolveGcseEditPathConcern

    before_action :set_previous_path, only: %i[new create]

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
        redirect_to resolve_gcse_edit_path(subject_param)
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

    def set_previous_path
      @previous_path = if current_qualification.non_uk_qualification_type.present?
                         candidate_interface_gcse_details_new_enic_path(subject: @subject)
                       else
                         candidate_interface_gcse_details_new_type_path(subject: @subject)
                       end
    end

    def enic_params
      strip_whitespace params
        .expect(candidate_interface_gcse_enic_form: %i[enic_reference comparable_uk_qualification])
    end
  end
end

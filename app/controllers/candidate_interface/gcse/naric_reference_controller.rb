module CandidateInterface
  class Gcse::NaricReferenceController < Gcse::DetailsController
    before_action :redirect_to_dashboard_if_submitted, :set_subject, :render_404_if_flag_is_inactive

    def edit
      @naric_reference_form = find_or_build_qualification_form
    end

    def update
      @naric_reference_form = find_or_build_qualification_form

      @naric_reference_form.set_attributes(naric_reference_params)


      if @naric_reference_form.save(@current_qualification)
        update_gcse_completed(false)

        redirect_to next_gcse_path
      else
        track_validation_error(@naric_reference_form)
        render :edit
      end
    end

  private

    def render_404_if_flag_is_inactive
      render_404 and return unless FeatureFlag.active?('international_gcses')
    end

    def find_or_build_qualification_form
      @current_qualification = current_application.qualification_in_subject(:gcse, subject_param)
      NaricReferenceForm.build_from_qualification(@current_qualification)
    end

    def next_gcse_path
      @details_form = GcseQualificationDetailsForm.build_from_qualification(
        current_application.qualification_in_subject(:gcse, subject_param),
      )
      if @details_form.qualification.grade.nil?
        candidate_interface_gcse_details_edit_grade_path
      else
        candidate_interface_gcse_review_path
      end
    end

    def naric_reference_params
      binding.pry
      params.require(:candidate_interface_naric_reference_form)
        .permit(:naric_reference_choice, :naric_reference, :comparable_uk_qualification,
        )
    end
  end
end

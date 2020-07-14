module CandidateInterface
  class Gcse::NaricReferenceController < Gcse::DetailsController
    before_action :redirect_to_dashboard_if_submitted, :set_subject, :render_404_if_flag_is_inactive

    def edit
      @naric_reference_form = NaricReferenceForm.new
    end

  private

    def render_404_if_flag_is_inactive
      render_404 and return unless FeatureFlag.active?('international_gcses')
    end
    #
    # def find_or_build_qualification_form
    #   @current_qualification = current_application.qualification_in_subject(:gcse, subject_param)
    #
    #   if @current_qualification
    #     GcseInstitutionCountryForm.build_from_qualification(@current_qualification)
    #   else
    #     GcseInstitutionCountryForm.new(
    #       subject: subject_param,
    #       level: ApplicationQualification.levels[:gcse],
    #     )
    #   end
    # end

    # def next_gcse_path
    #   @details_form = GcseQualificationDetailsForm.build_from_qualification(
    #     current_application.qualification_in_subject(:gcse, subject_param),
    #   )
    #   if @details_form.qualification.grade.nil?
    #     candidate_interface_gcse_details_edit_naric_reference_path
    #   else
    #     candidate_interface_gcse_review_path
    #   end
    # end
  end
end

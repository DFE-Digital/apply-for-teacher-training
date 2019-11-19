module CandidateInterface
  class Gcse::DetailsController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    before_action :set_subject

    # 2nd step - Edit grade and award year
    def edit
      @application_qualification = GcseQualificationDetailsForm.build_from_qualification(
        current_application.qualification_in_subject(:gcse, subject_param),
      )
      @qualification_type = @application_qualification.qualification.qualification_type
    end

    def update
      details_form = GcseQualificationDetailsForm.build_from_qualification(
        current_application.qualification_in_subject(:gcse, subject_param),
      )

      details_form.grade = details_params[:grade]
      details_form.award_year = details_params[:award_year]

      @application_qualification = details_form.save_base

      if @application_qualification
        redirect_to candidate_interface_gcse_review_path
      else
        @application_qualification = details_form

        render :edit
      end
    end

  private

    def set_subject
      @subject = subject_param
    end

    def subject_param
      params.require(:subject)
    end

    def details_params
      params.require(:candidate_interface_gcse_qualification_details_form).permit(%i[grade award_year])
    end
  end
end

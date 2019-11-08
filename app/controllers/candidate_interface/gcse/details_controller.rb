module CandidateInterface
  class Gcse::DetailsController < CandidateInterfaceController
    before_action :set_subject

    # 2nd step - Edit grade and award year
    def edit
      application_qualification = ApplicationQualification.last

      @application_qualification = GcseQualificationDetailsForm.new(
        grade: application_qualification.grade,
        award_year: application_qualification.award_year,
      )
    end

    def update
      current_application_qualification = ApplicationQualification.last

      details_form = GcseQualificationDetailsForm.new(
        grade: params[:candidate_interface_gcse_qualification_details_form][:grade],
        award_year: params[:candidate_interface_gcse_qualification_details_form][:award_year],
      )

      @application_qualification = details_form.save_base(current_application_qualification)

      if @application_qualification
        redirect_to candidate_interface_gcse_review_path
      else
        @application_qualification = details_form

        render :edit_details
      end
    end

    def review
      @application_qualification = ApplicationQualification.last

      render :review
    end

  private

    def set_subject
      @subject = subject_param
    end

    def subject_param
      params.require(:subject)
    end
  end
end

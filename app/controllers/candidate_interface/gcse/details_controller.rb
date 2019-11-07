module CandidateInterface
  class Gcse::DetailsController < CandidateInterfaceController
    before_action :set_subject

    # 2nd step - Edit grade and award year
    def edit
      @application_qualification = GcseQualificationDetailsForm.build_from_qualification(current_qualification)
    end

    def update
      details_form = GcseQualificationDetailsForm.build_from_qualification(current_qualification)

      details_form.grade = params[:candidate_interface_gcse_qualification_details_form][:grade]
      details_form.award_year = params[:candidate_interface_gcse_qualification_details_form][:award_year]

      @application_qualification = details_form.save_base

      if @application_qualification
        redirect_to candidate_interface_gcse_review_path
      else
        @application_qualification = details_form

        render :edit
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

    def current_qualification
      current_candidate
        .current_application
        .application_qualifications
        .where(level: ApplicationQualification.levels[:gcse], subject: subject_param)
        .first
    end
  end
end

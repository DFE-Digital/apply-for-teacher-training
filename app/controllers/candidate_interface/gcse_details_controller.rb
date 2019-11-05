module CandidateInterface
  class GcseDetailsController < CandidateInterfaceController
    before_action do
      @subject = subject_param
    end

    # 1th step - Edit qualification type
    def edit_type
      @application_qualification = GcseQualificationTypeForm.new(
        subject: subject_param,
        level: ApplicationQualification.levels[:gcse],
      )
    end

    def update_type
      @application_qualification = GcseQualificationTypeForm.new(qualification_type: qualification_type_param,
                                                                 subject: subject_param,
                                                                 level: ApplicationQualification.levels[:gcse])

      application_form = current_candidate.current_application

      if @application_qualification.save_base(application_form)
        redirect_to candidate_interface_gcse_details_edit_details_path
      else
        render :edit_type
      end
    end

    # 2nd step - Edit grade and award year
    def edit_details
      application_qualification = ApplicationQualification.last

      @application_qualification = GcseQualificationDetailsForm.new(
        grade: application_qualification.grade,
        award_year: application_qualification.award_year,
      )

      render :edit_details
    end

    def update_details
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
    def subject_param
      params.require(:subject)
    end

    def qualification_type_param
      (params[:candidate_interface_gcse_qualification_type_form] || {}).fetch(:qualification_type, '')
    end
  end
end

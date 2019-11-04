module CandidateInterface
  class GcseDetailsController < CandidateInterfaceController
    # 1th step - Edit qualification type
    def edit_type
      @subject = subject_param

      @application_qualification = GcseQualificationTypeForm.new(
        qualification_type: '',
        subject: subject_param,
        level: 'gcse',
      )
    end

    def update_type
      @subject = subject_param
      @application_qualification = GcseQualificationTypeForm
                                     .new(qualification_type: (params[:candidate_interface_gcse_qualification_type_form] || {}).fetch(:qualification_type, ''),
                                          subject: subject_param,
                                          level: 'gcse')

      application_form = current_candidate.current_application

      if @application_qualification.save_base(application_form)
        redirect_to candidate_interface_gcse_details_edit_details_path
      else
        render :edit_type
      end
    end

    # 2nd step - Edit grade and award year
    def edit_details
      @subject = subject_param
      application_qualification = ApplicationQualification.last

      @application_qualification = gcse_qualification_details_form(
        grade: application_qualification.grade,
        award_year: application_qualification.award_year,
)

      render :edit_details
    end

    def update_details
      @subject = subject_param
      current_application_qualification = ApplicationQualification.last

      details_form = gcse_qualification_details_form(
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
      @subject = subject_param
      @application_qualification = ApplicationQualification.last

      render :review
    end

  private

    def gcse_qualification_details_form(grade:, award_year:)
      GcseQualificationDetailsForm.new(
        grade: grade,
        award_year: award_year,
      )
    end

    def subject_param
      params[:subject]
    end
  end
end

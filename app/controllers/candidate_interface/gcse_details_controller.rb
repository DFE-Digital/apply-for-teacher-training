module CandidateInterface
  class GcseDetailsController < CandidateInterfaceController
    def edit_type
      subject = params[:subject]

      @application_qualification = GcseQualificationTypeForm .new(qualification_type: '',  subject: subject,  level: 'gcse')
    end

    def update_type
      subject = params[:subject]

      @application_qualification = GcseQualificationTypeForm
                                     .new(qualification_type: (params[:candidate_interface_gcse_qualification_type_form] || {}).fetch(:qualification_type, ''),
                                          subject: subject,
                                          level: 'gcse')

      application_form = current_candidate.current_application

      if @application_qualification.save_base(application_form)
        redirect_to candidate_interface_gcse_details_edit_details_path
      else
        render :edit_type
      end
    end

    def edit_details
      @application_qualification = ApplicationQualification.last
      # edit grade and award year
      render :edit_details
    end

    def update_details
      @application_qualification = ApplicationQualification.last

      redirect_to candidate_interface_gcse_review_path
    end

    def review
      @application_qualification = ApplicationQualification.last

      render :review
    end

  end
end

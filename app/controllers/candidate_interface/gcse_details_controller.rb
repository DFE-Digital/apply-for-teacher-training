module CandidateInterface
  class GcseDetailsController < CandidateInterfaceController
    def edit_type
      subject = params[:subject]

      @application_qualification = ApplicationQualification.new(subject: subject)


    end

    def update_type
      @application_qualification = ApplicationQualification.create(subject: params[:subject], application_form: current_candidate.current_application, level: 'gcse')

      redirect_to candidate_interface_gcse_details_edit_details_path
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

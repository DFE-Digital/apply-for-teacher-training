module CandidateInterface
  class GcseDetailsController < CandidateInterfaceController
    def edit_type
      subject = params[:subject]

      @application_qualification = ApplicationQualification.create(subject: subject, application_form: current_candidate.current_application, level: 'gcse')
    end

    def update
      @application_qualification = ApplicationQualification.last

      render :show
    end
  end
end

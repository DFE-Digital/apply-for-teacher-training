module CandidateInterface
  class GcseDetailsController < CandidateInterfaceController
    def edit
      subject = params[:subject]
      @heading = t("gcse_details.heading.#{subject}")

      @application_qualification = ApplicationQualification.create(subject: subject, application_form: current_candidate.current_application, level: 'gcse')
    end

    def update
      application_qualifications = ApplicationQualification.last

      application_qualifications = current_candidate.current_application.application_qualifications

      @heading = t("gcse_summary.heading.#{application_qualifications.subject}")
      render :show
    end
  end
end


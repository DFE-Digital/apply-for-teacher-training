module CandidateInterface
  class Gcse::TypeController < CandidateInterfaceController
    before_action :set_subject

    # 1th step - Edit qualification type
    def edit
      @application_qualification = if current_qualification
                                     GcseQualificationTypeForm.build_from_qualification(current_qualification)
                                   else
                                     GcseQualificationTypeForm.new(
                                       subject: subject_param,
                                       level: ApplicationQualification.levels[:gcse],
                                       )
                                   end
    end

    def update
      if current_qualification
        @application_qualification = GcseQualificationTypeForm.build_from_qualification(current_qualification)
      else
        @application_qualification ||= GcseQualificationTypeForm.new(subject: subject_param, level: ApplicationQualification.levels[:gcse])
      end

      @application_qualification.qualification_type = qualification_type_param

      application_form = current_candidate.current_application

      if @application_qualification.save_base(application_form)
        redirect_to candidate_interface_gcse_details_edit_details_path
      else
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

    def qualification_type_param
      (params[:candidate_interface_gcse_qualification_type_form] || {}).fetch(:qualification_type, '')
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

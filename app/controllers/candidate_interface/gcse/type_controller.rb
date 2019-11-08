module CandidateInterface
  class Gcse::TypeController < CandidateInterfaceController
    before_action :set_subject

    # 1th step - Edit qualification type
    def edit
      @application_qualification = GcseQualificationTypeForm.new(
        subject: subject_param,
        level: ApplicationQualification.levels[:gcse],
      )
    end

    def update
      @application_qualification = GcseQualificationTypeForm.new(qualification_type: qualification_type_param,
                                                                 subject: subject_param,
                                                                 level: ApplicationQualification.levels[:gcse])

      if @application_qualification.save_base(current_application)
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
  end
end

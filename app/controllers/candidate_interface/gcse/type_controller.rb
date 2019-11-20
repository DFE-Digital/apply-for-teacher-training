module CandidateInterface
  class Gcse::TypeController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    # 1th step - Edit qualification type
    def edit
      @application_qualification = find_or_build_qualification_form
    end

    def update
      @application_qualification = find_or_build_qualification_form

      @application_qualification.set_attributes(qualification_params)

      if @application_qualification.save_base(current_candidate.current_application)
        redirect_to next_gcse_path
      else
        render :edit
      end
    end

  private

    def find_or_build_qualification_form
      current_qualification = current_application.qualification_in_subject(:gcse, subject_param)

      if current_qualification
        GcseQualificationTypeForm.build_from_qualification(current_qualification)
      else
        GcseQualificationTypeForm.new(
          subject: subject_param,
          level: ApplicationQualification.levels[:gcse],
        )
      end
    end

    def set_subject
      @subject = subject_param
    end

    def subject_param
      params.require(:subject)
    end

    def next_gcse_path
      if @application_qualification.missing_qualification?
        candidate_interface_gcse_review_path
      else
        candidate_interface_gcse_details_edit_details_path
      end
    end

    def qualification_params
      params.require(:candidate_interface_gcse_qualification_type_form)
        .permit(:qualification_type, :other_uk_qualification_type, :missing_explanation)
    end
  end
end

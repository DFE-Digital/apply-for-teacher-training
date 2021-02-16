module CandidateInterface
  class Gcse::ReviewController < Gcse::BaseController
    before_action :set_field_name
    before_action :render_application_feedback_component, except: :complete

    def show
      @application_form = current_application
      @application_qualification = current_application.qualification_in_subject(:gcse, subject_param)
    end

    def complete
      @application_form = current_application
      @application_qualification = current_application.qualification_in_subject(:gcse, subject_param)

      if @application_qualification.incomplete_gcse_information? && !@application_qualification.missing_qualification?
        flash[:warning] = 'You cannot mark this section complete with incomplete GCSE information.'
        render :show
      else
        current_application.update!(application_form_params)

        redirect_to candidate_interface_application_form_path
      end
    end

  private

    def set_field_name
      @field_name = "#{@subject}_gcse_completed"
    end

    def application_form_params
      strip_whitespace params.require(:application_form).permit(@field_name)
    end
  end
end

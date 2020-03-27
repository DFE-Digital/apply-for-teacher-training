module SupportInterface
  class ApplicationFormsController < SupportInterfaceController
    def index
      @application_forms = ApplicationForm.includes(:candidate, :application_choices).sort_by(&:updated_at).reverse
    end

    def show
      @application_form = application_form
    end

    def audit
      @application_form = application_form
    end

    def select_course_to_add
      @form = SupportInterface::AddCourseToApplicationForm.new(application_form: application_form)
    end

    def add_course
      course_option_id = params.require(:support_interface_add_course_to_application_form).fetch(:course_option_id)

      @form = SupportInterface::AddCourseToApplicationForm.new(
        application_form: application_form,
        course_option_id: course_option_id,
      )

      if @form.save
        redirect_to support_interface_application_form_path(application_form)
      else
        render :select_course_to_add
      end
    end

    def application_form
      @_application_form ||= ApplicationForm.find(params[:application_form_id])
    end
  end
end

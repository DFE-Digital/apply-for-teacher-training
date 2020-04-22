module SupportInterface
  class ChangeCourseController < SupportInterfaceController
    before_action :make_sure_course_can_be_added, only: %w[select_course_to_add add_choice]
    before_action :make_sure_course_can_be_withdrawn, only: %w[select_choice_to_withdraw withdraw_choice]

    def options
      @change_course_form = SupportInterface::ChangeCourseForm.new(application_form: application_form)
    end

    def pick_option
      @change_course_form = SupportInterface::ChangeCourseForm.new(
        params.require(:support_interface_change_course_form).permit(:change_type),
      )

      render :options unless @change_course_form.valid?

      case @change_course_form.change_type
      when 'add_course'
        redirect_to support_interface_add_course_to_application_path(application_form)
      when 'withdraw_choice'
        redirect_to support_interface_withdraw_choice_path(application_form)
      when 'cancel_application'
        redirect_to support_interface_cancel_application_path(application_form)
      end
    end

    def select_course_to_add
      @form = SupportInterface::AddCourseToApplicationForm.new(application_form: application_form)
    end

    def add_choice
      course_option_id = params.require(:support_interface_add_course_to_application_form).fetch(:course_option_id)

      @form = SupportInterface::AddCourseToApplicationForm.new(
        application_form: application_form,
        course_option_id: course_option_id,
      )

      if @form.save
        flash[:success] = 'Course added to application'
        redirect_to support_interface_application_form_path(application_form)
      else
        render :select_course_to_add
      end
    end

    def select_choice_to_withdraw
      @form = SupportInterface::WithdrawChoiceForm.new(application_form: application_form)
    end

    def withdraw_choice
      @form = SupportInterface::WithdrawChoiceForm.new(
        application_form: application_form,
        application_choice_id: params.dig(:support_interface_withdraw_choice_form, :application_choice_id),
      )

      if @form.save
        flash[:success] = 'The course choice has been withdrawn'
        redirect_to support_interface_application_form_path(application_form)
      else
        render :select_course_to_cancel
      end
    end

    def confirm_cancel_application
      @application_form = application_form
    end

    def cancel_application
      SupportInterface::CancelApplicationForm.new(application_form: application_form).save!
      redirect_to support_interface_application_form_path(application_form)
    end

  private

    def application_form
      @_application_form ||= ApplicationForm.find(params[:application_form_id])
    end

    def make_sure_course_can_be_added
      pick_option_form = SupportInterface::ChangeCourseForm.new(application_form: application_form)

      unless pick_option_form.can_add_course?
        flash[:warning] = 'This application already has 3 courses'
        redirect_to support_interface_change_course_path(application_form)
      end
    end

    def make_sure_course_can_be_withdrawn
      pick_option_form = SupportInterface::ChangeCourseForm.new(application_form: application_form)

      unless pick_option_form.can_withdraw_course?
        flash[:warning] = 'The last course of an application can\'t be removed'
        redirect_to support_interface_change_course_path(application_form)
      end
    end
  end
end

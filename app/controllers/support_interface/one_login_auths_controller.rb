module SupportInterface
  class OneLoginAuthsController < SupportInterfaceController
    before_action :set_application_form
    def edit
      @candidate = @application_form.candidate
      @unlink_form = UnlinkOneLoginAuthForm.new(candidate: @candidate)
    end

    def update
      @candidate = @application_form.candidate
      @unlink_form = UnlinkOneLoginAuthForm.new(audit_comment: form_params[:audit_comment], candidate: @candidate)

      if @unlink_form.valid?
        @unlink_form.save
        flash[:success] = t('.success')

        redirect_to support_interface_application_form_path(@application_form)
      else
        render :edit
      end
    end

  private

    def set_application_form
      @application_form = ApplicationForm.find(params[:application_form_id])
    end

    def form_params
      params.expect(
        support_interface_unlink_one_login_auth_form: :audit_comment,
      )
    end
  end
end

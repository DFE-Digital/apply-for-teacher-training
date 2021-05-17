module SupportInterface
  class ApplicationChoiceConditionsController < SupportInterfaceController
    def edit
      @form = SupportInterface::ConditionsForm.build_from_application_choice(application_choice)
    end

    def confirm_make_unconditional
      @form = SupportInterface::ConditionsForm.build_from_application_choice(
        application_choice,
        audit_comment_ticket: params[:audit_comment_ticket],
      )
    end

    def update
      @form = SupportInterface::ConditionsForm.build_from_params(
        application_choice,
        condition_params,
      )

      if @form.conditions_empty? && !@form.confirm_make_unconditional?
        redirect_to support_interface_confirm_make_application_choice_unconditional_path(
          @form.application_choice.id,
          audit_comment_ticket: @form.audit_comment_ticket,
        )
      elsif @form.save
        flash[:success] = 'Offer conditions updated'
        redirect_to support_interface_application_form_path(@form.application_choice.application_form_id)
      else
        render :edit
      end
    end

    def make_unconditional
      @form = SupportInterface::ConditionsForm.build_from_params(
        application_choice,
        condition_params,
      )

      if  @form.save
        flash[:success] = 'Offer conditions updated'
        redirect_to support_interface_application_form_path(@form.application_choice.application_form_id)
      else
        render :confirm_make_unconditional
      end
    end

  private

    def application_choice
      @application_choice = ApplicationChoice.find(params[:application_choice_id])
    end

    def condition_params
      params
        .require(:support_interface_conditions_form)
        .permit(:application_choice_id, :audit_comment_ticket, :confirm_make_unconditional, further_conditions: {}, standard_conditions: [])
        .to_h
        .with_indifferent_access
    end
  end
end

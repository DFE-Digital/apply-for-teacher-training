module CandidateInterface
  module WithdrawalReasons
    class SecondaryReasonsController < WithdrawalReasonsController
      def start
        @secondary_reasons_form = SecondaryReasonsForm.build_from_application_choice(primary_reason, @application_choice)
      end

      def continue
        @secondary_reasons_form = SecondaryReasonsForm.new(form_params, application_choice: @application_choice)
        if @secondary_reasons_form.valid?
          @secondary_reasons_form.create!
          redirect_to candidate_interface_withdrawal_reasons_secondary_reasons_review_path
        else
          render :start
        end
      end

      def withdraw
        WithdrawApplication.new(application_choice: @application_choice).save!
        flash[:success] = I18n.t(
          'candidate_interface.withdrawal_reasons.success_message',
          provider_name: @application_choice.current_course_option.provider.name,
        )
        redirect_to candidate_interface_application_complete_path(@application_choice)
      end

      def review
        @secondary_reasons_form = SecondaryReasonsForm.new(
          { primary_reason: },
          application_choice: @application_choice,
          withdrawal_reasons: @application_choice.withdrawal_reasons,
        )
      end

      def cancel
        @application_choice.draft_withdrawal_reasons.each(&:destroy!)
        redirect_to candidate_interface_application_complete_path(@application_choice)
      end

    private

      def form_params
        params.require(:candidate_interface_withdrawal_reasons_secondary_reasons_form)
              .permit(:comment, :personal_circumstances_reasons_comment, secondary_reasons: [], personal_circumstances_reasons: [])
              .merge({ primary_reason: })
      end

      def primary_reason
        params[:primary_reason]
      end
    end
  end
end

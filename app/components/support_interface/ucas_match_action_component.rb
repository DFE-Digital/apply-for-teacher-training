module SupportInterface
  class UCASMatchActionComponent < ViewComponent::Base
    include ViewHelper

    ACTIONS = {
      send_initial_emails: {
        description: 'Send initial emails',
        button_text: 'Confirm initial emails were sent',
        form_path: :support_interface_record_initial_emails_sent_path,
      },
      send_reminder_emails: {
        description: 'Send reminder emails',
        button_text: 'Confirm reminder emails were sent',
        form_path: :support_interface_record_reminder_emails_sent_path,
      },
      request_withdrawal_from_ucas: {
        description: 'Request withdrawal from UCAS',
        button_text: 'Confirm withdrawal from UCAS was requested',
        form_path: :support_interface_record_ucas_withdrawal_requested_path,
        instructions: "We need to contact UCAS. Please send an encrypted file with the candidate's duplicate application details to Harry Haines (h.haines@ucas.ac.uk) and Lizzy Carter (l.carter@ucas.ac.uk) from UCAS to ask them to remove the candidate from UTT.",
      },
      confirm_withdrawal_from_ucas: {
        description: 'Confirm withdrawal from UCAS',
        button_text: 'Confirm the application was withdrawn from UCAS',
        form_path: :support_interface_process_match_path,
        instructions: "We need to ensure that UCAS have removed the candidate's duplicate application from UTT.",
      },
    }.freeze

    def initialize(match)
      @match = match
    end

    def inset_text_header
      return 'No action required' if !@match.dual_application_or_dual_acceptance? || !@match.action_needed?

      type_of_action
    end

    def action_details
      return '' unless @match.dual_application_or_dual_acceptance?

      @match.action_needed? ? required_action_details : last_action_details
    end

    def button
      {
        text: ACTIONS[next_action][:button_text],
        path: Rails.application.routes.url_helpers.send(ACTIONS[next_action][:form_path], @match),
      }
    end

  private

    def next_action
      if @match.candidate_last_contacted_at.nil?
        :send_initial_emails
      elsif @match.initial_emails_sent? && @match.need_to_send_reminder_emails?
        :send_reminder_emails
      elsif @match.reminder_emails_sent? && @match.need_to_request_withdrawal_from_ucas?
        :request_withdrawal_from_ucas
      elsif @match.ucas_withdrawal_requested?
        :confirm_withdrawal_from_ucas
      end
    end

    def type_of_action
      "<strong class='govuk-tag govuk-tag--yellow app-tag'>Action needed</strong> #{ACTIONS[next_action][:description]}".html_safe
    end

    def required_action_details
      instructions = ACTIONS[next_action][:instructions] ||
        "We need to contact the candidate and the provider. Use the appropriate Zendesk macro. Alternatively, you can use the appropriate template from <a class='govuk-link' href='https://docs.google.com/document/d/1s5ql4jNUUr3QDPUQYWImkZR6o8upvutrjOEuoZ0qqTE'>this document</a>."
      support_manual_info = "<br><br>Please refer to <a class='govuk-link' href='https://docs.google.com/document/d/1XvZiD8_ng_aG_7nvDGuJ9JIdPu6pFdCO2ujfKeFDOk4'>Dual-running user support manual</a> for more information about the current process."

      instructions.concat(support_manual_info).html_safe
    end

    def last_action_details
      last_action = if @match.initial_emails_sent?
                      'sent the initial emails'
                    elsif @match.reminder_emails_sent?
                      'sent the reminder emails'
                    elsif @match.processed? && @match.ucas_withdrawal_requested?
                      'confirmed that the candidate was withdrawn from UCAS. We contacted UCAS to request removal from UTT'
                    end

      "We #{last_action} on the #{@match.candidate_last_contacted_at.to_s(:govuk_date_and_time)}"
    end
  end
end

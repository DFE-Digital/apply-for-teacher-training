module SupportInterface
  class UCASMatchActionComponent < ViewComponent::Base
    include ViewHelper

    ACTIONS = {
      initial_emails_sent: {
        description: 'Send initial emails',
        instructions: 'Emails to the candidate and the provider will be sent automatically.',
        past_tense_description: 'sent the initial emails',
      },
      reminder_emails_sent: {
        description: 'Send a reminder email',
        instructions: 'A reminder email to the candidate will be sent automatically.',
        past_tense_description: 'sent the reminder emails',
      },
      ucas_withdrawal_requested: {
        description: 'Request withdrawal from UCAS',
        button_text: 'Confirm withdrawal from UCAS was requested',
        form_path: :support_interface_record_ucas_withdrawal_requested_path,
        instructions: 'We need to contact UCAS. Please send the trackable applicant key and the candidate’s duplicate application details to Harry Haines (h.haines@ucas.ac.uk) and Lizzy Carter (l.carter@ucas.ac.uk) from UCAS to ask them to remove the candidate from UTT.',
        past_tense_description: 'requested withdrawal from UCAS',
      },
      resolved_on_ucas: {
        past_tense_description: 'confirmed that the candidate was withdrawn from UCAS',
      },
      resolved_on_apply: {
        past_tense_description: 'confirmed that the candidate was withdrawn from Apply',
      },
      manually_resolved: {
        past_tense_description: 'resolved the match manually',
      },
    }.freeze

    def initialize(match)
      @match = match
    end

    def inset_text_header
      return 'No action required' unless @match.action_needed?

      type_of_action
    end

    def action_details
      return '' unless @match.dual_application_or_dual_acceptance?

      @match.action_needed? ? required_action_details : last_action_details
    end

    def button
      next_action = @match.next_action
      {
        text: ACTIONS[next_action][:button_text],
        path: Rails.application.routes.url_helpers.send(ACTIONS[next_action][:form_path], @match),
      }
    end

  private

    def type_of_action
      capture do
        concat govuk_tag(text: 'Action needed', colour: 'yellow')
        concat ' '
        concat ACTIONS[@match.next_action][:description]
      end
    end

    def required_action_details
      capture do
        concat tag.p(ACTIONS[@match.next_action][:instructions])
        concat tag.p("Please refer to #{govuk_link_to('Dual-running user support manual', 'https://docs.google.com/document/d/1XvZiD8_ng_aG_7nvDGuJ9JIdPu6pFdCO2ujfKeFDOk4')} for more information about the current process.".html_safe)
      end
    end

    def last_action_details
      last_action = @match.last_action
      tag.p("We #{ACTIONS[last_action][:past_tense_description]} on the #{@match.candidate_last_contacted_at.to_s(:govuk_date_and_time)}")
    end
  end
end

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
      end
    end

    def type_of_action
      "<strong class='govuk-tag govuk-tag--yellow app-tag'>Action needed</strong> #{ACTIONS[next_action][:description]}".html_safe
    end

    def required_action_details
      "We need to contact the candidate and the provider. Use the appropriate Zendesk macro. Alternatively, you can use the appropriate template from <a class='govuk-link' href='https://docs.google.com/document/d/1s5ql4jNUUr3QDPUQYWImkZR6o8upvutrjOEuoZ0qqTE'>this document</a>.".html_safe
    end

    def last_action_details
      last_action = if @match.initial_emails_sent?
                      'sent the initial emails'
                    elsif @match.reminder_emails_sent?
                      'sent the reminder emails'
                    end

      "We #{last_action} on the #{@match.candidate_last_contacted_at.to_s(:govuk_date_and_time)}"
    end
  end
end

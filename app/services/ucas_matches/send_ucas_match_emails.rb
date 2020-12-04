module UCASMatches
  class SendUCASMatchEmails
    include Sidekiq::Worker

    def perform
      ucas_matches_requiring_action.each do |ucas_match|
        case ucas_match.next_action
        when :initial_emails_sent
          UCASMatches::SendUCASMatchInitialEmails.new(ucas_match).call
        when :reminder_emails_sent
          UCASMatches::SendUCASMatchReminderEmails.new(ucas_match).call
        end
      end
    end

  private

    def send_and_record_initial_emails(ucas_match)
      if UCASMatches::SendUCASMatchInitialEmails.new(ucas_match).call
        UCASMatches::RecordActionTaken.new(ucas_match, :initial_emails_sent).call
      end
    end

    def send_and_record_reminder_email(ucas_match)
      if UCASMatches::SendUCASMatchReminderEmails.new(ucas_match).call
        UCASMatches::RecordActionTaken.new(ucas_match.id, :reminder_emails_sent).call
      end
    end

    def ucas_matches_requiring_action
      UCASMatch.all.select(&:action_needed?)
    end
  end
end

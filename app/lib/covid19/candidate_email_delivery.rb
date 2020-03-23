module Covid19
  class CandidateEmailDelivery
    def send_delay_emails
      skip_email_statuses = %w(
       withdrawn rejected declined conditions_not_met recruited enrolled
      )

      # Find all candidates that need emailing
      candidates = Candidate.includes(application_forms: [:application_choices])

      candidates_to_email = candidates.select do |candidate|
        application_form = candidate.current_application
        if application_form.application_choices.all? { |ac| ac.status.in? skip_email_statuses }
          false
        else
          true
        end
      end

      # Send emails async
      candidates_to_email.each do |candidate|
        CandidateMailer.covid_19_delay(candidate.current_application).deliver_later
      end
    end
  end
end

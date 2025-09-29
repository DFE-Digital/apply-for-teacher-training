module CandidateInterface
  class PreferencesEmail
    attr_reader :preference, :application_form

    def initialize(preference:)
      @preference = preference
      @application_form = preference.application_form
    end

    def self.call(preference:)
      new(preference:).call
    end

    def call
      if preference.opt_in? && send_first_opt_in_email?
        CandidateMailer.pool_opt_in(application_form).deliver_later
      end
    end

  private

    def send_first_opt_in_email?
      application_form.emails.where(mail_template: 'pool_opt_in').blank?
    end
  end
end

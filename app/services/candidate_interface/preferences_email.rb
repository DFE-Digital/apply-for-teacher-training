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
      if preference.opt_in? && never_opted_in?
        CandidateMailer.pool_opt_in(application_form).deliver_later
      elsif preference.opt_out? && never_opted_in?
        CandidateMailer.pool_opt_out(application_form).deliver_later
      elsif preference.opt_out?
        CandidateMailer.pool_opt_out_after_opting_in(application_form).deliver_later
      elsif preference.opt_in?
        CandidateMailer.pool_re_opt_in(application_form).deliver_later
      end
    end

  private

    def never_opted_in?
      application_form.emails.where(mail_template: 'pool_opt_in').blank?
    end
  end
end

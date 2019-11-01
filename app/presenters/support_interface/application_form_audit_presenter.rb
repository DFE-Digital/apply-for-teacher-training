module SupportInterface
  class ApplicationFormAuditPresenter
    attr_accessor :application_form

    def initialize(application_form)
      self.application_form = application_form
    end

    def audits
      # TODO: Another presenter?
      application_form.own_and_associated_audits
    end

    def full_name
      "#{application_form.first_name} #{application_form.last_name}"
    end
  end
end

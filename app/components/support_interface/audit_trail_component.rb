module SupportInterface
  class AuditTrailComponent < ActionView::Component::Base
    include ViewHelper

    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def audits
      application_form.own_and_associated_audits
    end

    attr_reader :application_form
  end
end

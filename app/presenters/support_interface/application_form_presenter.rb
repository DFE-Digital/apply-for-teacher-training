module SupportInterface
  class ApplicationFormPresenter
    def initialize(application_form)
      @application_form = application_form
    end

    def full_name
      "#{application_form.first_name} #{application_form.last_name}"
    end

    def updated_at
      application_form.updated_at.strftime('%e %b %Y at %l:%M%P')
    end

    def date_of_birth
      application_form.date_of_birth
    end

    def email_and_support_reference
      if application_form.support_reference
        "#{application_form.candidate.email_address} (#{application_form.support_reference})"
      else
        application_form.candidate.email_address
      end
    end

    def to_param
      application_form.id.to_s
    end

    def first_reference_status
      reference_status(application_form.references[0])
    end

    def second_reference_status
      reference_status(application_form.references[1])
    end

  private

    def submitted?
      application_form.submitted_at.present?
    end

    def reference_status(reference)
      return 'Not applicable' unless reference && submitted?

      reference.complete? ? 'Received' : 'Awaiting response'
    end

    attr_reader :application_form
  end
end

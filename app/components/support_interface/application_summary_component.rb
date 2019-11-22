module SupportInterface
  class ApplicationSummaryComponent < ActionView::Component::Base
    include ViewHelper

    delegate :first_name,
             :last_name,
             :phone_number,
             :support_reference,
             :submitted_at,
             :submitted?,
             :updated_at,
             :candidate,
             :application_choices,
             to: :application_form

    delegate :email_address, to: :candidate

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        name_row,
        support_reference_row,
        email_row,
        phone_number_row,
        choices_row,
        submitted_row,
        last_updated_row,
      ].compact
    end

  private

    def name_row
      if first_name
        {
          key: 'Name',
          value: "#{first_name} #{last_name}",
        }
      end
    end

    def email_row
      {
        key: 'Email address',
        value: mail_to(email_address, email_address, class: 'govuk-link'),
      }
    end

    def phone_number_row
      if phone_number
        {
          key: 'Phone number',
          value: phone_number,
        }
      end
    end

    def choices_row
      if application_choices.any?
        {
          key: 'Course choices',
          value: application_choices.map do |a|
            href = "https://find-postgraduate-teacher-training.education.gov.uk/course/#{a.course.provider.code}/#{a.course.code}"
            text = "#{a.course.name_and_code} at #{a.course.provider.name_and_code}"
            govuk_link_to(text, href)
          end,
        }
      end
    end

    def last_updated_row
      {
        key: 'Last updated',
        value: "#{updated_at.strftime('%e %b %Y at %l:%M%P')} (#{govuk_link_to('History', support_interface_application_form_audit_path(application_form))})",
      }
    end

    def submitted_row
      if submitted?
        {
          key: 'Submitted',
          value: submitted_at.strftime('%e %b %Y at %l:%M%P'),
        }
      end
    end

    def support_reference_row
      if support_reference
        {
          key: 'Support reference',
          value: support_reference,
        }
      end
    end

    attr_reader :application_form
  end
end

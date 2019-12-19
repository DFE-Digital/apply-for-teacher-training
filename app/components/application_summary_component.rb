class ApplicationSummaryComponent < ActionView::Component::Base
  include ViewHelper

  delegate :first_name,
           :last_name,
           :phone_number,
           :candidate,
           to: :application_form

  delegate :email_address, to: :candidate

  def initialize(application_form:)
    @application_form = application_form
  end

  def rows
    [
      name_row,
      email_row,
      phone_number_row,
    ].compact
  end

private

  def name_row
    if first_name
      {
        key: 'Full name',
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

  attr_reader :application_form
end

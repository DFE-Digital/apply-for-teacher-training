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
      date_of_birth_row,
      nationality_row,
      phone_number_row,
      email_row,
      address_row,
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

  def nationality_row
    formatted_nationalities = [@application_form.first_nationality, @application_form.second_nationality].reject(&:blank?).to_sentence

    {
      key: 'Nationality',
      value: formatted_nationalities,
    }
  end

  def date_of_birth_row
    {
      key: 'Date of birth',
      value: @application_form.date_of_birth.strftime('%e %B %Y'),
    }
  end

  def address_row
    full_address = [
      @application_form.address_line1,
      @application_form.address_line2,
      @application_form.address_line3,
      @application_form.address_line4,
      @application_form.postcode,
    ].reject(&:blank?)

    {
      key: 'Address',
      value: full_address,
    }
  end

  attr_reader :application_form
end

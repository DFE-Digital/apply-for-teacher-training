class ContactDetailsReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:)
    @application_form = application_form
    @contact_details_form = CandidateInterface::ContactDetailsForm.build_from_application(
      @application_form,
    )
  end

  def contact_details_form_rows
    [phone_number_row, address_row]
  end

private

  attr_reader :application_form

  def phone_number_row
    {
      key: t('application_form.contact_details.phone_number.label'),
      value: @contact_details_form.phone_number,
      action: t('application_form.contact_details.phone_number.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_contact_details_edit_base_path,
    }
  end

  def address_row
    {
      key: t('application_form.contact_details.full_address.label'),
      value: full_address,
      action: t('application_form.contact_details.full_address.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_contact_details_edit_address_path,
    }
  end

  def full_address
    [
      @contact_details_form.address_line1,
      @contact_details_form.address_line2,
      @contact_details_form.address_line3,
      @contact_details_form.address_line4,
      @contact_details_form.postcode,
    ]
      .reject(&:blank?)
  end
end

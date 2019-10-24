class ContactDetailsComponent < ActionView::Component::Base
  validates :contact_details_form, presence: true

  def initialize(contact_details_form:)
    @contact_details_form = contact_details_form
  end

  def contact_details_form_rows
    [phone_number_row]
  end

private

  attr_reader :contact_details_form

  def phone_number_row
    {
      key: t('application_form.contact_details.phone_number.label'),
      value: @contact_details_form.phone_number,
      action: t('application_form.contact_details.phone_number.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_contact_details_edit_path,
    }
  end
end

class ZendeskUrlValidator < ActiveModel::Validator
  ZENDESK_URL = /\A((http|https):\/\/)?(www.)?becomingateacher.zendesk.com\/agent\/tickets\//.freeze

  def validate(record)
    field = record.respond_to?(:audit_comment) ? :audit_comment : :audit_comment_ticket

    if record.send(field) !~ ZENDESK_URL
      record.errors.add(field, 'Enter a valid Zendesk ticket URL')
    end
  end
end

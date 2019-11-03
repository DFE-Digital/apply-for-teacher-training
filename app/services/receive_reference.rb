class ReceiveReference
  attr_reader :referee_email
  attr_reader :reference

  include ActiveModel::Validations

  validates_presence_of :referee_email
  validate :referee_must_exist_on_application_form

  def initialize(application_form:, referee_email:, reference:)
    @application_form = application_form
    @referee_email = referee_email
    @reference = reference
  end

  def save
    return unless valid?

    @application_form
    .references
    .find_by!(email_address: @referee_email)
    .update(reference: @reference)
  end

private

  def referee_must_exist_on_application_form
    if @application_form.references.where(email_address: @referee_email).empty?
      errors.add(:referee_email, 'does not match any of the provided referees')
    end
  end
end

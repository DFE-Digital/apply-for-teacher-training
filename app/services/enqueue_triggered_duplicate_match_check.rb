class EnqueueTriggeredDuplicateMatchCheck
  ADDRESS_FIELDS = %w[address_line1 address_line2 address_line3 address_line4 postcode address_type country].freeze
  PERSONAL_FIELDS = %w[last_name date_of_birth].freeze

  def initialize(application_form)
    @application_form = application_form
    @original_attributes = application_form.attributes.slice(*(ADDRESS_FIELDS + PERSONAL_FIELDS))
  end

  def call
    yield.tap do |saved|
      if saved && check_required?
        UpdateTriggeredDuplicateMatchesWorker.perform_later(@application_form.id)
      end
    end
  end

private

  def check_required?
    return false if @application_form.last_name.blank? || @application_form.date_of_birth.blank?

    changed_fields = @original_attributes.keys.reject do |field|
      @original_attributes[field] == @application_form.public_send(field)
    end

    changed_fields.intersect?(ADDRESS_FIELDS) ||
      (changed_fields.intersect?(PERSONAL_FIELDS) && address_entered?)
  end

  def address_entered?
    %w[postcode address_line1 address_line2 address_line3 address_line4].any? do |field|
      @application_form.public_send(field).present?
    end
  end
end

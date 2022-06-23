class RetrieveAPIFieldLength
  API_SPECIFICATION = VendorAPISpecification.new.as_hash
  FIELD_LENGTHS_SUMMARY = APIDocs::APIReference.new(API_SPECIFICATION).field_lengths_summary
  attr_reader :field

  def initialize(field)
    @field = field
  end

  def call
    FIELD_LENGTHS_SUMMARY.to_h["#{field}.maxLength"].to_i
  end
end

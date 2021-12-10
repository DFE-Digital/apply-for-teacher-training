class RetrieveAPIFieldLength
  attr_reader :field

  def initialize(field)
    @field = field
  end

  def call
    APIDocs::APIReference.new(VendorAPISpecification.new.as_hash).field_lengths_summary.to_h["#{field}.maxLength"].to_i
  end
end

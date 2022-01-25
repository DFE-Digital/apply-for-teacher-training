class VendorAPI::InterviewPresenter < VendorAPI::Base
  attr_reader :interview

  def initialize(version, interview)
    super(version)
    @interview = interview
  end

  def as_json
    schema.to_json
  end

  def schema
    {
      id: interview.id.to_s,
      provider_code: interview.provider.code,
      date_and_time: interview.date_and_time.iso8601,
      location: interview.location,
      additional_details: interview.additional_details,
      cancelled_at: interview.cancelled_at&.iso8601,
      cancellation_reason: interview.cancellation_reason,
      created_at: interview.created_at.iso8601,
      updated_at: interview.updated_at.iso8601,
    }
  end
end

class LookupAreaByPostcodeWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  retry_on StandardError, attempts: 5

  attr_reader :application_form

  def perform(application_form_id)
    @application_form = ApplicationForm.find(application_form_id)
    return if application_form&.postcode.blank?

    application_form.update!(region_code:, postcode:)
  end

private

  def region_code
    if result&.region.present?
      REGION_CODES[result.region.downcase]
    elsif result&.country.present?
      REGION_CODES[result.country.downcase]
    end
  end

  def postcode
    result&.postcode || application_form.postcode
  end

  def result
    @result ||= Postcodes::IO.new.lookup(application_form.postcode)
  end
end

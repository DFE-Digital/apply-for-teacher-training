class ReferenceStatus
  attr_reader :application_form

  def initialize(application_form)
    @application_form = application_form
  end

  def still_more_references_needed?
    number_of_references_that_currently_need_replacing.positive?
  end

  def number_of_references_that_currently_need_replacing
    references_that_needed_to_be_replaced.size - replacement_references.reject(&:not_requested_yet?).size
  end

  def needs_to_draft_another_reference?
    (number_of_references_that_currently_need_replacing - references_currently_not_requested_yet.size).positive?
  end

  def references_that_needed_to_be_replaced
    refused = application_references.select(&:feedback_refused?)
    bounced = application_references.select(&:email_bounced?)
    ignored = application_references.select(&:feedback_overdue?)

    refused + bounced + ignored
  end

private

  def references_currently_not_requested_yet
    application_references.select(&:not_requested_yet?)
  end

  def replacement_references
    application_references.select(&:replacement?)
  end

  def feedback_completed?
    application_references.select(&:feedback_provided?).size == 2
  end

  def application_references
    @application_references ||= application_form.application_references.to_a
  end
end

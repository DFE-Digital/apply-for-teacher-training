class CancelOutstandingReferences
  attr_reader :application_form

  delegate :application_references, :show_new_reference_flow?, to: :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def call!
    return unless show_new_reference_flow?

    application_references.feedback_requested.each do |reference|
      CancelReferee.new.call(reference: reference)
    end
  end
end

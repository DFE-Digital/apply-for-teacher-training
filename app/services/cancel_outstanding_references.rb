class CancelOutstandingReferences
  attr_reader :application_form

  delegate :application_references, to: :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def call!
    application_references.feedback_requested.each do |reference|
      CancelReferee.new.call(reference: reference)
    end
  end
end

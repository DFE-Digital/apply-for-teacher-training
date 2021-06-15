class ResolveUCASMatch
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    match = UCASMatches::RetrieveForApplicationChoice.new(@application_choice).call

    if match&.ready_to_resolve? && match&.duplicate_applications_withdrawn_from_apply?
      UCASMatches::ResolveOnApply.new(match).call
    end
  end
end

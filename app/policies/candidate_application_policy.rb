class CandidateApplicationPolicy
  def initialize(user, candidate_application)
    @user = user
    @candidate_application = candidate_application
  end

  def done_by_candidate?
    @user == 'candidate'
  end

  def done_by_referee?
    @user == 'referee'
  end

  def done_by_provider?
    @user == 'provider'
  end

  alias_method :submit?, :done_by_candidate?
  alias_method :accept_offer?, :done_by_candidate?

  alias_method :submit_reference?, :done_by_referee?

  alias_method :make_conditional_offer?, :done_by_provider?
  alias_method :make_unconditional_offer?, :done_by_provider?
  alias_method :confirm_conditions_met?, :done_by_provider?
  alias_method :confirm_onboarding?, :done_by_provider?
  alias_method :reject?, :done_by_provider?
  alias_method :add_conditions?, :done_by_provider?
  alias_method :amend_conditions?, :done_by_provider?
end

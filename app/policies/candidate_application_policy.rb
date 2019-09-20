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
    @user.start_with?('provider')
  end

  alias_method :submit?, :done_by_candidate?
  alias_method :accept_offer?, :done_by_candidate?
  alias_method :decline_offer?, :done_by_candidate?

  alias_method :submit_reference?, :done_by_referee?

  alias_method :make_conditional_offer?, :done_by_provider?
  alias_method :make_unconditional_offer?, :done_by_provider?
  alias_method :confirm_conditions_met?, :done_by_provider?
  alias_method :confirm_onboarding?, :done_by_provider?
  alias_method :reject?, :done_by_provider?

  def update_conditions?
    provider_code = @user.scan(/provider \((.*)\)/).flatten.last
    done_by_provider? && @candidate_application.course.provider_or_accredited_body?(provider_code)
  end

  alias_method :add_conditions?, :update_conditions?
  alias_method :amend_conditions?, :update_conditions?
end

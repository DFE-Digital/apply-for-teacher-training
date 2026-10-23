module AuthorizeSupportUserCandidateEditable
  extend ActiveSupport::Concern

  included do
    before_action :authorize_support_user
  end

private

  def authorize_support_user
    authorize nil, :edit?, policy_class: SupportInterface::CandidatePolicy
  end
end

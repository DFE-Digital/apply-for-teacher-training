class CandidateInterface::SignInCandidateForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email_address, :string

  validates :email_address, presence: true, length: { maximum: 100 }, valid_for_notify: true

  def candidate
    if potential_sign_in?
      return potential_candidate_for_sign_in
    end

    candidate = Candidate.new(email_address:)

    unless potential_sign_up?
      candidate.errors.add(:email_address, 'Not viable for sign-in or sign-up')
    end

    candidate
  end

  def potential_candidate_for_sign_in
    Candidate.joins(:one_login_auth).find_by(one_login_auth: { email_address: }).presence || Candidate.where.missing(:one_login_auth).find_by(email_address:).presence
  end

  alias potential_sign_in? potential_candidate_for_sign_in

  def potential_sign_up?
    valid? && OneLoginAuth.find_by(email_address:).nil? && Candidate.find_by(email_address:).nil?
  end
end

module CandidateInterface
  class SignUpForm
    include ActiveModel::Model
    attr_accessor :email_address, :accept_ts_and_cs, :candidate

    validates :email_address, :accept_ts_and_cs, presence: true
    validates :email_address, length: { maximum: 100 }

    validate :candidate_email_address_is_valid

    def initialize(params = {})
      @email_address = params[:email_address]
      @accept_ts_and_cs = params[:accept_ts_and_cs]
      @candidate = Candidate.for_email @email_address
    end

    def existing_candidate?
      candidate.persisted?
    end

    def save
      return false if existing_candidate? || !valid?

      candidate.save
    end

  private

    def candidate_email_address_is_valid
      if candidate && candidate.invalid?
        candidate.errors[:email_address].each do |error|
          errors.add(:email_address, error)
        end
      end
    end
  end
end

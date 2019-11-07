module CandidateInterface
  class SignUpForm
    include ActiveModel::Model

    attr_accessor :email_address, :accept_ts_and_cs
    validates :email_address, :accept_ts_and_cs, presence: true
    NOTIFY_EMAIL_REGEXP = %r{\A[a-zA-Z0-9.!#$%&'*+=?^_`{|}~\\-]+@([^.@][^@\\s]+)\z}.freeze
    validates :email_address, format: { with: NOTIFY_EMAIL_REGEXP }


    def save_base(candidate)
      unless candidate.valid?
        candidate.errors[:email_address].each{|error| errors.add(:email_address, error)}
      end

      # need the explicit empty? check on errors as we're
      # delegating email address validation to the candidate
      # and just copying the messages
      return false unless valid? && errors.empty?
      candidate.update!(email_address: email_address)
    end

    def self.build_from_candidate(candidate)
      new( email_address: candidate.email_address )
    end
  end
end

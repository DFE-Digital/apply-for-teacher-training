module CandidateInterface
  class SignUpForm
    include ActiveModel::Model
    attr_accessor :email_address, :accept_ts_and_cs, :candidate, :course_from_find_id

    validates :email_address, :accept_ts_and_cs, presence: true
    validates :email_address, length: { maximum: 100 }

    validate :candidate_email_address_has_access
    validate :candidate_email_address_is_valid

    def initialize(params = {})
      @email_address = params[:email_address]
      @accept_ts_and_cs = params[:accept_ts_and_cs]
      @candidate = Candidate.for_email @email_address
      @course_from_find_id = params[:course_from_find_id]
    end

    def existing_candidate?
      candidate.persisted?
    end

    def save
      return false if existing_candidate? || !valid?

      candidate.course_from_find_id = course_from_find_id
      candidate.event_tags = ['candidate_sign_up']
      candidate.save
    end

  private

    def candidate_email_address_has_access
      if HostingEnvironment.dfe_signup_only? &&
         email_address.present? &&
         !email_address.match(/education\.gov\.uk$/)
        errors.add(:email_address, :dfe_signup_only)
      end
    end

    def candidate_email_address_is_valid
      if candidate&.invalid?
        candidate.errors[:email_address].each do |error|
          errors.add(:email_address, error)
        end
      end
    end
  end
end

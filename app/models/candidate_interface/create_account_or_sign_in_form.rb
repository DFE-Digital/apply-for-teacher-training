module CandidateInterface
  class CreateAccountOrSignInForm
    include ActiveModel::Model

    attr_accessor :existing_account

    validates :existing_account, presence: true

    def existing_account?
      ActiveModel::Type::Boolean.new.cast(existing_account)
    end
  end
end

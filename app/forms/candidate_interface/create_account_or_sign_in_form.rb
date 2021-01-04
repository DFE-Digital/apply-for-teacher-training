module CandidateInterface
  class CreateAccountOrSignInForm
    include ActiveModel::Model

    attr_accessor :existing_account, :email

    validates :existing_account, presence: true
    validates :email, presence: true, valid_for_notify: true, if: -> { existing_account? }

    def existing_account?
      ActiveModel::Type::Boolean.new.cast(existing_account)
    end
  end
end

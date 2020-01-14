module SupportInterface
  class SendReferenceEmailForm
    include ActiveModel::Model

    attr_accessor :choice, :new_referee_email

    validates :choice, presence: true
    validates :new_referee_email, presence: true, if: :new_referee_email?

    def chase?
      choice == 'chase'
    end

    def new_referee_email?
      choice == 'new_referee'
    end
  end
end

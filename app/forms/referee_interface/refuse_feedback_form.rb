module RefereeInterface
  class RefuseFeedbackForm
    include ActiveModel::Model

    attr_accessor :choice

    validates :choice, presence: true

    def referee_has_confirmed_they_wont_a_reference?
      choice == 'yes'
    end
  end
end

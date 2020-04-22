module ProviderInterface
  class NewNoteForm
    include ActiveModel::Model
    attr_accessor :application_choice, :title, :message, :provider_user

    validates :application_choice, :title, :message, :provider_user, presence: true
    validates :title, length: { maximum: 40 }

    def save
      if valid?
        Note.new(
          application_choice: application_choice,
          provider_user: provider_user,
          title: title,
          message: message,
        ).save
      end
    end
  end
end

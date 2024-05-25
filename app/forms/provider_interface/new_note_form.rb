module ProviderInterface
  class NewNoteForm
    include ActiveModel::Model

    attr_accessor :application_choice, :message, :referer, :user
    attr_reader :service

    delegate :errors, to: :service

    def initialize(attrs = {})
      super
      @service = CreateNote.new(
        application_choice:,
        user:,
        message:,
      )
    end

    def save
      if service.valid?
        service.save!
      end
    end
  end
end

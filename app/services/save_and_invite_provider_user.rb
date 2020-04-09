class SaveAndInviteProviderUser
  attr_reader :form, :save_service, :invite_service

  def initialize(form:, save_service:, invite_service:)
    @form = form
    @save_service = save_service
    @invite_service = invite_service
  end

  def call
    if form.valid?
      ActiveRecord::Base.transaction do
        save_service.call!
        invite_service.call!
      end
    end
  rescue DfeSignInApiError => e
    e.errors.each { |error| form.errors.add(:base, error) }
  end
end

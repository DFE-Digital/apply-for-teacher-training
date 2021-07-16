class SaveAndInviteProviderUser
  attr_reader :form, :save_service, :invite_service, :new_user

  def initialize(form:, save_service:, invite_service:, new_user: true)
    @form = form
    @save_service = save_service
    @invite_service = invite_service
    @new_user = new_user
  end

  def call
    return false unless form.valid?

    begin
      ActiveRecord::Base.transaction do
        save_service.call!
        invite_service.call! if new_user
      end
      invite_service.notify
    rescue DfeSignInAPIError => e
      form.errors.add(
        :base,
        'A problem occurred inviting this user. Please try again. If problems persist, please contact support.',
      )
      Sentry.capture_exception(e)

      return false
    end

    true
  end
end

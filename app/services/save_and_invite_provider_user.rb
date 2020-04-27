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
    rescue DfeSignInAPIError
      form.errors.add(
        :base,
        'A problem occurred inviting this user. Please try again. If problems persist, please contact support.',
      )
      return false
    end

    true
  end
end

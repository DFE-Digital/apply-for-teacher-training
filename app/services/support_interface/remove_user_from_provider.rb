module SupportInterface
  class RemoveUserFromProvider
    attr_accessor :permissions_to_remove, :provider_user, :provider

    def initialize(permissions_to_remove:)
      @permissions_to_remove = permissions_to_remove
      @provider_user = permissions_to_remove.provider_user
      @provider = permissions_to_remove.provider
    end

    def call!
      permissions_to_remove.destroy!

      send_permissions_removed_email
    end

  private

    def send_permissions_removed_email
      ProviderMailer.permissions_removed(provider_user, provider).deliver_later
    end
  end
end

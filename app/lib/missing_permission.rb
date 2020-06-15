class MissingPermission < RuntimeError
  attr_reader :permission, :provider, :provider_user

  def initialize(permission:, provider:, provider_user:)
    @permission = permission
    @provider = provider
    @provider_user = provider_user
  end
end

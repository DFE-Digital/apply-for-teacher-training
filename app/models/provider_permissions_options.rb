class ProviderPermissionsOptions
  include ActiveModel::Model

  VALID_PERMISSIONS = %i[manage_users].freeze

  attr_accessor(*VALID_PERMISSIONS)

  def self.valid?(permission_name)
    VALID_PERMISSIONS.include?(permission_name.to_sym)
  end

  def self.reset_attributes
    {}.tap do |hsh|
      VALID_PERMISSIONS.each { |p| hsh[p] = false }
    end
  end
end

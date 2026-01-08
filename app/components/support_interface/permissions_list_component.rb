module SupportInterface
  class PermissionsListComponent < BaseComponent
    attr_reader :permission_model

    def initialize(permission_model)
      @permission_model = permission_model
    end
  end
end

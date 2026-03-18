module SupportInterface
  class PermissionsListComponent < ApplicationComponent
    attr_reader :permission_model

    def initialize(permission_model)
      @permission_model = permission_model
    end
  end
end

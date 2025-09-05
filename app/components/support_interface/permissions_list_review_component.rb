module SupportInterface
  class PermissionsListReviewComponent < ApplicationComponent
    attr_reader :permissions

    def initialize(permissions)
      @permissions = permissions
    end
  end
end

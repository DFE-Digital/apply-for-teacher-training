module SupportInterface
  class PermissionsListReviewComponent < BaseComponent
    attr_reader :permissions

    def initialize(permissions)
      @permissions = permissions
    end
  end
end

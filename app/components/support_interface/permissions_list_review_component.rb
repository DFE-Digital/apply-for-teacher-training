module SupportInterface
  class PermissionsListReviewComponent < ViewComponent::Base
    attr_reader :permissions

    def initialize(permissions)
      @permissions = permissions
    end
  end
end

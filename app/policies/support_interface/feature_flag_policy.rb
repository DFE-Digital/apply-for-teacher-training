module SupportInterface
  class FeatureFlagPolicy < ApplicationPolicy
    def show?
      true
    end

    def edit?
      # return true if user.technical_role? || user.business_role?
      #
      # false
      true
    end
  end
end

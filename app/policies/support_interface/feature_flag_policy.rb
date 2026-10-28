module SupportInterface
  class FeatureFlagPolicy < ApplicationPolicy
    def show?
      true
    end

    def edit?
      # return true if user.technical_management_role? || user.service_administration_role?
      #
      # false
      true
    end
  end
end

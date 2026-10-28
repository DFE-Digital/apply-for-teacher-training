module SupportInterface
  class SupportUserPolicy < ApplicationPolicy
    def show?
      # return true if user.user_support_role? || user.technical_management_role? || user.service_administration_role?
      #
      # false
      true
    end
    alias index? show?

    def new?
      # return true if user.user_support_role? || user.technical_management_role?
      #
      # false
      true
    end
    alias create? new?

    def edit?
      # return true if user.technical_management_role?
      #
      # return true if user.user_support_role? && record != user
      #
      # false
      true
    end
    alias update? edit?

    def destroy?
      # return true if user.technical_management_role?
      #
      # return true if user.user_support_role? && record != user
      #
      # false
      true
    end
  end
end

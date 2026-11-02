module SupportInterface
  class SupportUserPolicy < ApplicationPolicy
    def show?
      return true if user.user_support_role? || user.technical_management_role? || user.service_administration_role?

      false
    end
    alias index? show?

    def new?
      return true if user.user_support_role? || user.technical_management_role?

      false
    end
    alias create? new?

    def edit?
      return true if user.technical_management_role?

      return true if user.user_support_role? && record != user

      false
    end
    alias update? edit?

    def destroy?
      return true if user.technical_management_role?

      return true if user.user_support_role? && record != user

      false
    end
  end
end

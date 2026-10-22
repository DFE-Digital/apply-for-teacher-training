module SupportInterface
  class SupportUserPolicy < ApplicationPolicy
    def show?
      return true if user.support_role? || user.technical_role? || user.business_role?

      false
    end
    alias index? show?

    def new?
      return true if user.support_role? || user.technical_role?

      false
    end
    alias create? new?

    def edit?
      return true if user.technical_role?

      return true if user.support_role? && record != user

      false
    end
    alias update? edit?

    def destroy?
      return true if user.technical_role?

      return true if user.support_role? && record != user

      false
    end
  end
end

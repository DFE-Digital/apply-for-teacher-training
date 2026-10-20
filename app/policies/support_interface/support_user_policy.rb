module SupportInterface
  class SupportUserPolicy < ApplicationPolicy
    def show?
      return true if user.support_role? || user.technical_role? || user.business_role?

      false
    end

    def edit?
      return true if user.support_role? || user.technical_role?

      false
    end
    alias new? edit?
    alias create? edit?
    alias update? edit?

    def destroy?
      return true if user.support_role? || user.technical_role?

      false
    end
  end
end

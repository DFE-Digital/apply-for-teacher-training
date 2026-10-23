module SupportInterface
  class SupportUserPolicy < ApplicationPolicy
    def show?
      # return true if user.support_role? || user.technical_role? || user.business_role?
      #
      # false
      true
    end
    alias index? show?

    def new?
      # return true if user.support_role? || user.technical_role?
      #
      # false
      true
    end
    alias create? new?

    def edit?
      # return true if user.technical_role?
      #
      # return true if user.support_role? && record != user
      #
      # false
      true
    end
    alias update? edit?

    def destroy?
      # return true if user.technical_role?
      #
      # return true if user.support_role? && record != user
      #
      # false
      true
    end
  end
end

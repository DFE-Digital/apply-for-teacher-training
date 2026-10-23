module SupportInterface
  class ProviderPolicy < ApplicationPolicy
    def show?
      true
    end

    # API tokens
    def edit?
      # return true if user.support_role? || user.technical_role?
      #
      # false
      true
    end
    alias new? edit?
    alias create? edit?
    alias update? edit?

    def destroy?
      # return true if user.support_role? || user.technical_role?
      #
      # false
      true
    end
  end
end

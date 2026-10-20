module SupportInterface
  class ServiceBannerPolicy < ApplicationPolicy
    def show?
      true
    end

    def edit?
      return true if user.technical_role? || user.business_role? || user.researcher_role?

      false
    end
    alias new? edit?
    alias create? edit?
    alias update? edit?

    def destroy?
      return true if user.technical_role? || user.business_role? || user.researcher_role?

      false
    end
  end
end

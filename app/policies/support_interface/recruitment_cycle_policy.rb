module SupportInterface
  class RecruitmentCyclePolicy < ApplicationPolicy
    def show?
      true
    end

    def edit?
      return true if user.technical_management_role? || user.service_administration_role?

      false
    end
    alias new? edit?
    alias create? edit?
    alias update? edit?

    def destroy?
      return true if user.technical_management_role? || user.service_administration_role?

      false
    end
  end
end

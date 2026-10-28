module SupportInterface
  class ServiceBannerPolicy < ApplicationPolicy
    def show?
      true
    end

    def edit?
      # return true if user.technical_management_role? || user.service_administration_role? || user.research_and_design_role?
      #
      # false
      true
    end
    alias new? edit?
    alias create? edit?
    alias update? edit?

    def destroy?
      # return true if user.technical_management_role? || user.service_administration_role? || user.research_and_design_role?
      #
      # false
      true
    end
  end
end

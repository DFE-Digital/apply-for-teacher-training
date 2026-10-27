module SupportInterface
  class CandidatePolicy < ApplicationPolicy
    def show?
      # return true if user.user_support_role? || user.technical_management_role? || user.research_and_design_role?
      #
      # false
      true
    end

    def edit?
      # return true if user.user_support_role? || user.technical_management_role?
      #
      # false
      true
    end
    alias new? edit?
    alias create? edit?
    alias update? edit?

    def destroy?
      # return true if user.user_support_role? || user.technical_management_role?
      #
      # false
      true
    end
  end
end

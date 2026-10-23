module SupportInterface
  class CandidatePolicy < ApplicationPolicy
    def show?
      # return true if user.support_role? || user.technical_role? || user.researcher_role?
      #
      # false
      true
    end

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

module SupportInterface
  class DeveloperToolPolicy < ApplicationPolicy
    def show?
      return true if user.technical_role? || user.researcher_role?

      false
    end

    def edit?
      return true if user.technical_role?

      false
    end
    alias new? edit?
    alias create? edit?
    alias update? edit?
  end
end

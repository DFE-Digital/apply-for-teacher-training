module SupportInterface
  class DeveloperToolPolicy < ApplicationPolicy
    def show?
      # return true if user.technical_management_role? || user.research_and_design_role?
      #
      # false
      true
    end
    # Blazer methods
    alias home? show?
    alias index? show?
    alias docs? show?
    alias schema? show?
    alias refresh? show?
    alias run? show?
    alias cancel? show?
    alias tables? show?

    def edit?
      # return true if user.technical_management_role?
      #
      # false
      true
    end
    alias new? edit?
    alias create? edit?
    alias update? edit?
    alias destroy? edit?
  end
end

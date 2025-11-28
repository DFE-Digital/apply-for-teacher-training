class ApplicationChoicePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(application_form_id: current_application.id)
    end
  end
end

module SupportInterface
  class ProviderPolicy < ApplicationPolicy
    def show?
      true
    end
  end
end

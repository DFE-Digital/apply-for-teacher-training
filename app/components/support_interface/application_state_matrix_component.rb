module SupportInterface
  class ApplicationStateMatrixComponent < ApplicationComponent
    def headers
      @headers ||= begin
        headers = scopes.map { |scope| scope.to_s.humanize }
        headers.prepend('States')
      end
    end

    def scopes
      @scopes ||= begin
        members = ApplicationStateChange::ApplicationState.members.sort
        members.delete(:id)
        members
      end
    end
  end
end

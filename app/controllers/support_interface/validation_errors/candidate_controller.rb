module SupportInterface
  module ValidationErrors
    class CandidateController < SupportInterface::ValidationErrors::UserController
      def service_scope
        :apply
      end
    end
  end
end

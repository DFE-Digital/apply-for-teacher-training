module CandidateInterface
  module Gcse
    module GradeControllerConcern
      extend ActiveSupport::Concern

      def update_gcse_completed(value)
        attribute_to_update = "#{@subject}_gcse_completed"
        current_application.update!("#{attribute_to_update}": value)
      end
    end
  end
end

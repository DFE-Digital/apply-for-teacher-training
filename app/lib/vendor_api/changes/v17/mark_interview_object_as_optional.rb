module VendorAPI
  module Changes
    module V17
      class MarkInterviewObjectAsOptional < VersionChange
        description 'Mark interview object as optional'

        action InterviewsController, :create
      end
    end
  end
end

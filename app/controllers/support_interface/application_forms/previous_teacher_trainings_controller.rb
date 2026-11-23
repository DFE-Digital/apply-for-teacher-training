module SupportInterface
  module ApplicationForms
    class PreviousTeacherTrainingsController < SupportInterfaceController
      include AuthorizeSupportUserCandidateEditable

      def edit
      end
    end
  end
end

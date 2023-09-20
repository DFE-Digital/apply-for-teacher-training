module CandidateInterface
  class SectionController < CandidateInterfaceController
    before_action :set_editable_section

    def set_editable_section
      @editable_section = EditableSection.new(
        current_application:,
        controller_path:,
        action_name:,
        params:,
      )
    end
  end
end

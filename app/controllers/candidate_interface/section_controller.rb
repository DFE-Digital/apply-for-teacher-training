module CandidateInterface
  class SectionController < CandidateInterfaceController
    before_action :set_editable_section
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :redirect_to_your_details_non_editable_sections, except: %i[show review]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    def set_editable_section
      @editable_section = EditableSection.new(
        current_application:,
        controller_path:,
        action_name:,
        params:,
      )
    end

    def redirect_to_your_details_non_editable_sections
      redirect_to candidate_interface_continuous_applications_details_path unless @editable_section.can_edit?
    end
  end
end

module CandidateInterface
  class EditableSectionWarningPreview < ViewComponent::Preview
    def editable_section
      render PreviewEditableSectionWarning.new(
        current_application:,
        section_policy: OpenStruct.new(can_edit?: true, personal_statement?: false, work_history?: false),
      )
    end

    def personal_statement
      render PreviewEditableSectionWarning.new(
        current_application:,
        section_policy: OpenStruct.new(can_edit?: true, personal_statement?: true, work_history?: false),
      )
    end

    def work_history
      render PreviewEditableSectionWarning.new(
        current_application:,
        section_policy: OpenStruct.new(can_edit?: true, personal_statement?: false, work_history?: true),
      )
    end

    def active_previous_application_jan_start_dates
      render PreviewEditableSectionWarning.new(
        current_application:,
        section_policy: OpenStruct.new(can_edit?: true, personal_statement?: false, work_history?: false),
        active_previous_application: true
      )
    end

  private

    def current_application
      FactoryBot.build(:completed_application_form, recruitment_cycle_year: 2026)
    end

    class PreviewEditableSectionWarning < CandidateInterface::EditableSectionWarning
      def initialize(current_application:, section_policy:, active_previous_application: false)
        super(current_application:, section_policy:)
        @active_previous_application = active_previous_application
      end

      def render?
        true
      end

      def active_previous_application
        return unless @active_previous_application

        FactoryBot.build(:completed_application_form, recruitment_cycle_year: 2025)
      end
    end
  end
end

module CandidateInterface
  module RestructuredWorkHistory
    class ReviewComponent < ViewComponent::Base
      def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
        @application_form = application_form
        @editable = editable
        @heading_level = heading_level
        @show_incomplete = show_incomplete
        @missing_error = missing_error
        @work_history_with_breaks = RestructuredWorkHistoryWithBreaks.new(@application_form).timeline
      end

      def show_missing_banner?
        @show_incomplete
      end

      def no_work_experience_rows
        if application_form.full_time_education?
          [
            {
              key: t('application_form.restructured_work_history.full_time_education.review_label'),
              value: no_work_experience_value,
              action: t('application_form.restructured_work_history.full_time_education.change_action'),
              change_path: @editable ? candidate_interface_restructured_work_history_path : nil,
            },
          ]
        else
          [
            {
              key: t('application_form.work_history.explanation.review_label'),
              value: no_work_experience_value,
              action: t('application_form.restructured_work_history.explanation.change_action'),
              change_path: @editable ? candidate_interface_restructured_work_history_path : nil,
            },
          ]
        end
      end

    private

      attr_reader :application_form

      def no_work_experience_value
        application_form.full_time_education? ? t('application_form.work_history.full_time_education.label') : application_form.work_history_explanation
      end

      def breaks_in_work_history?
        CheckBreaksInWorkHistory.call(@application_form)
      end
    end
  end
end

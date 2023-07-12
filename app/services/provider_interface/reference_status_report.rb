module ProviderInterface
  class ReferenceStatusReport
    attr_reader :provider_application_references, :context

    def initialize(provider)
      @provider = provider
    end

    def headers
      I18n.t('provider_interface.reference_status_report.headers')
    end

    def rows
      filtered_rows = report_data.select do |row|
        %w[feedback_requested feedback_provided].include?(row.feedback_status)
      end
      return [] if filtered_rows.nil?

      grouped_rows = filtered_rows.group_by { |row| row.application_form.full_name }

      grouped_rows.map do |full_name, rows|
        {
          header: full_name,
          link: application_link(rows.first),
          values: rows.map do |row|
            [
              row.name,
              feedback_status_label(row.feedback_status),
            ]
          end,
        }
      end
    end

    def application_link(row)
      Rails.application.routes.url_helpers.provider_interface_application_choice_references_path(row.application_choice_id)
    end

    def feedback_status_label(status)
      I18n.t("provider_interface.reference_status_report.feedback_status_labels.#{status}", default: 'Other')
    end

    def report_data
      @provider
        .application_references
        .joins(application_form: { application_choices: :course_option })
        .where(
          application_choices: {
            status: ApplicationStateChange::SUCCESSFUL_STATES - [:offer],
          },
        )
          .where.not(application_choices: { accepted_at: nil })
          .includes(:application_form)
          .select(
            '"references".*,
      "application_choices".id as application_choice_id',
          )
          .distinct
    end
  end
end

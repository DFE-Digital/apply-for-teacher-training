module ProviderInterface
  module RecruitmentPerformanceReport
    class SubjectTableComponent < ViewComponent::Base
      attr_reader :provider, :table_caption, :summary_row, :subject_rows
      def initialize(provider, table_caption:, summary_row:, subject_rows:)
        @provider = provider
        @table_caption = table_caption
        @summary_row = summary_row
        @subject_rows = subject_rows
      end

      def format_number(row, column_name)
        number = row.send(column_name)

        # The field may be 'Not available'
        return number unless number.respond_to?(:to_i)

        # If we aren't showing percentage change data, it's because the other columns are also percentages
        # (ie. comparing proportions of proportions doesn't make sense)
        if !show_percentage_change_data? || column_name.in?(%i[percentage_change national_percentage_change])
          number_to_percentage(number.to_d * 100, precision: 0)
        else
          number_with_delimiter(number.to_i)
        end
      end

      def show_percentage_change_data?
        @show_percentage_change_data ||= subject_rows.any? { |subject_row| subject_row.percentage_change.present? }
      end

      def colspan
        show_percentage_change_data? ? '3' : '2'
      end

      def width
        show_percentage_change_data? ? 'one-third' : 'one-half'
      end

      def provider_name
        @provider.name
      end

      def columns
        table_columns = %i[this_cycle last_cycle national_this_cycle national_last_cycle]
        if show_percentage_change_data?
          table_columns.insert(2, :percentage_change)
          table_columns.append(:national_percentage_change)
        end

        table_columns
      end

      def subheading_html_attributes(column_name)
        html_class = column_name == :national_this_cycle ? 'border-left' : 'no-border'

        { html_attributes: { class: "recruitment_performance_report_table__subhead--#{html_class}" } }
      end

      def numeric_html_attributes(column_name)
        return {} unless column_name == :national_this_cycle

        { html_attributes: { class: 'recruitment_performance_report_table__cell--border-left' } }
      end

      def level_html_attributes(subject_row)
        return {} if subject_row.level == 'Level'

        { html_attributes: { class: 'recruitment_performance_report_table__header--secondary-subject' } }
      end
    end
  end
end

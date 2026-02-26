module DfE
  module Bigquery
    class NonDisclosureTraineeWithdrawals
      include ::DfE::Bigquery::Relation

      SELECT_COLUMNS = %w[trainee_start_date
                          accredited_provider.name
                          accredited_provider.code
                          withdraw.date].freeze

      attr_reader :candidate

      def initialize(candidate:)
        @candidate = candidate
      end

      def table_name
        '1_key_tables.non_disclosure_trainee_withdrawals'
      end

      def trainee_data
        return [] if first_names.blank? || last_names.blank? || date_of_birth.blank?

        query(trainee_data_query)
      end

      def trainee_data_query
        select(SELECT_COLUMNS.join(', '))
        .where(sql_statement).to_sql
      end

    private

      def application_forms
        @application_forms ||= candidate.application_forms
      end

      def sql_statement
        ActiveRecord::Base.send(
          :sanitize_sql_for_conditions,
          ['email = ? OR (first_name IN (?) AND last_name IN (?) AND date_of_birth = ?)', candidate.email_address, first_names, last_names, date_of_birth],
        )
      end

      def first_names
        @first_names ||= application_forms.map { |application_form| application_form.first_name&.downcase }.compact.uniq
      end

      def last_names
        @last_names ||= application_forms.map { |application_form| application_form.last_name&.downcase }.compact.uniq
      end

      def date_of_birth
        @date_of_birth ||= application_forms.sample.date_of_birth.to_s
      end

      def result_class = self.class::Result

      class Result
        ATTRIBUTES = SELECT_COLUMNS.map { |column| column.to_s.split('.').last }
        attr_reader(*ATTRIBUTES)

        def initialize(attributes)
          attributes.each do |key, value|
            if respond_to?(key)
              instance_variable_set("@#{key}", value)
            end
          end
        end

        def attributes
          ATTRIBUTES.each_with_object({}) do |curr, obj|
            obj[curr.to_s] = public_send(curr)
          end
        end
      end
    end
  end
end

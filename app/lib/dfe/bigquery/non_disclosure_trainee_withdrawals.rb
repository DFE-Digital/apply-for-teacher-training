module DfE
  module Bigquery
    class NonDisclosureTraineeWithdrawals
      include ::DfE::Bigquery::Relation

      SELECT_COLUMNS = %w[trn
                          start_academic_year
                          trainee_id
                          created_at
                          training_route
                          training_route_category
                          trainee_start_date

                          accredited_provider.name
                          accredited_provider.type
                          accredited_provider.id
                          accredited_provider.code
                          accredited_provider.ukprn
                          accredited_provider.apply_sync_enabled

                          course.education_phase
                          course.allocation_subject
                          course.allocation_subject_id
                          course.tad_subject
                          course.subject_one
                          course.subject_two
                          course.subject_three
                          course.min_age
                          course.max_age
                          course.uuid

                          withdraw.category
                          withdraw.structured_reason
                          withdraw.free_text_reason
                          withdraw.future_interest
                          withdraw.trigger
                          withdraw.date].freeze

      attr_reader :candidate

      def initialize(candidate:)
        @candidate = candidate
      end

      def table_name
        '1_key_tables.non_disclosure_trainee_withdrawals'
      end

      def trainee_data
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
          ['email = ? OR (first_name IN (?) AND last_name IN (?) AND date_of_birth = ?)',
           candidate.email_address,
           first_names,
           last_names,
           application_forms.sample.date_of_birth&.strftime('%d/%m/%Y')],
        )
      end

      def first_names
        application_forms.pluck(:first_name).uniq
      end

      def last_names
        application_forms.pluck(:last_name).uniq
      end

      def result_class = self.class::Result

      class Result
        ATTRIBUTES = SELECT_COLUMNS.map { |column| column.to_s.tr('.', '_') }
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

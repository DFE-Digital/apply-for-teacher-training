class BulkCreateTestApplications
  attr_reader :template_application_form, :candidate, :application_choice

  def initialize(template_application_form)
    @template_application_form = template_application_form
    @candidate = template_application_form.candidate
    @application_choice = template_application_form.application_choices.first
  end

  def call
    error_if_application_choice_state_is_not_unsubmitted

    begin
      tries ||= 0
      sql = compose_insert_statements(unique_id: SecureRandom.hex(10))
      ActiveRecord::Base.connection.execute(sql)
    rescue ActiveRecord::RecordNotUnique
      retry unless (tries += 1) > 3
      raise UniqueCandidateError, 'Failed to create a uniquely identifiable candidate, tried 3 times'
    end
  end

private

  def error_if_application_choice_state_is_not_unsubmitted
    unless application_choice.unsubmitted?
      raise UnsupportedApplicationStateError, 'This task currently only supports template applications that are unsubmitted'
    end
  end

  def compose_insert_statements(unique_id:)
    candidate_field_names_sql, candidate_values_to_persist = compose_sql_fragments(
      candidate,
      ignore_fields: %w[id magic_link_token magic_link_token_sent_at],
      custom_fields: { 'email_address' => "#{unique_id}@example.com" },
    )
    application_form_field_names_sql, application_form_values_to_persist = compose_sql_fragments(
      template_application_form,
      ignore_fields: %w[id candidate_id],
      custom_fields: { 'last_name' => unique_id },
    )
    application_choice_field_names_sql, application_choice_values_to_persist = compose_sql_fragments(
      application_choice,
      ignore_fields: %w[id application_form_id],
    )

    <<~SQL
      WITH created_candidate AS (
        INSERT INTO "candidates" ( #{candidate_field_names_sql})
        VALUES ( #{candidate_values_to_persist})
        RETURNING "id"
      ),
       created_application_form AS (
        INSERT INTO "application_forms" ( #{application_form_field_names_sql}, candidate_id )
        VALUES ( #{application_form_values_to_persist}, (SELECT id FROM created_candidate) )
        RETURNING "id"
      )

      INSERT INTO "application_choices" ( #{application_choice_field_names_sql}, application_form_id )
      VALUES ( #{application_choice_values_to_persist}, (SELECT id FROM created_application_form) )
      RETURNING "id"
    SQL
  end

  def compose_sql_fragments(model, ignore_fields: [], custom_fields: {})
    attr = model.attributes
    ignore_fields.each { |f| attr.delete(f) }
    attr.merge!(custom_fields)
    field_names = attr.keys

    field_names_sql = field_names.join(', ')
    values_to_persist = field_names.map do |field|
      value = attr[field]
      if value == '' || value.nil?
        'NULL'
      elsif value.class == Hash
        # Gracefully switch from Hash syntax to JSON when dealing with json model fields
        "'#{value.to_json}'"
      else
        "'#{value}'"
      end
    end.join(', ')

    [field_names_sql, values_to_persist]
  end

  class UniqueCandidateError < StandardError; end
  class UnsupportedApplicationStateError < StandardError; end
end

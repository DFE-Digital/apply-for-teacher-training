class BulkCreateTestApplications
  attr_reader :template_application_form, :candidate, :application_choice

  def initialize(template_application_form)
    @template_application_form = template_application_form
    @candidate = template_application_form.candidate
    @application_choice = template_application_form.application_choices.first
  end

  def call
    random_id = SecureRandom.hex(10)

    candidate_field_names_sql, candidate_values_to_persist = compose_sql_fragments(
      candidate,
      ignore_fields: %w[id magic_link_token magic_link_token_sent_at],
      custom_fields: { 'email_address' => "#{random_id}@example.com" },
    )
    application_form_field_names_sql, application_form_values_to_persist = compose_sql_fragments(
      template_application_form,
      ignore_fields: %w[id candidate_id],
      custom_fields: { 'last_name' => random_id },
    )
    application_choice_field_names_sql, application_choice_values_to_persist = compose_sql_fragments(
      application_choice,
      ignore_fields: %w[id application_form_id],
    )

    query = <<~SQL
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

    ActiveRecord::Base.connection.execute(query)
  end

  def compose_sql_fragments(model, ignore_fields: [], custom_fields: {})
    attr = model.attributes
    ignore_fields.each { |f| attr.delete(f) }
    attr.merge!(custom_fields)
    field_names = attr.keys

    field_names_sql = field_names.join(', ')
    values_to_persist = field_names.map { |f|
      value = attr[f]
      if value == '' || value.nil?
        'NULL'
      elsif value.class == Hash
        # Gracefully switch from Hash syntax to JSON when dealing with json model fields
        "'#{value.to_json}'"
      else
        "'#{value}'"
      end
    }.join(', ')

    [field_names_sql, values_to_persist]
  end
end

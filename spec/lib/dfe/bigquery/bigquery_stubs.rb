module BigqueryStubs
  def stub_response(rows: nil)
    default_rows = [
      [
        { name: 'cycle_week', type: 'INTEGER', value: '7' },
        { name: 'number_of_candidates_submitted_to_date', type: 'INTEGER', value: '100' },
        { name: 'nonsubject_filter_category',             type: 'STRING',  value: 'Provider name' },
        { name: 'first_date_in_week',                     type: 'DATE',    value: '2024-03-18' },
        { name: 'subject_filter',                         type: 'STRING',  value: nil },
      ],
    ]
    rows ||= default_rows

    fields = rows.first.map do |cell|
      Google::Apis::BigqueryV2::TableFieldSchema.new(name: cell[:name], type: cell[:type], mode: 'NULLABLE')
    end

    processed_rows = rows.map do |row|
      processed_row = row.map do |cell|
        Google::Apis::BigqueryV2::TableCell.new(v: cell[:value])
      end

      Google::Apis::BigqueryV2::TableRow.new(f: processed_row)
    end

    schema = Google::Apis::BigqueryV2::TableSchema.new(fields:)
    instance_double(Google::Apis::BigqueryV2::QueryResponse, rows: processed_rows, schema:)
  end
end

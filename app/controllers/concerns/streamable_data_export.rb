module StreamableDataExport
  def streamable_response(filename:, export_data:, export_headers: nil, item_yielder: proc { |item| item })
    streamable_response_headers(filename)
    response.status = 200
    streamable_response_body(export_headers: export_headers, export_data: export_data, item_yielder: item_yielder)
  end

private

  def streamable_response_headers(filename)
    headers.delete('Content-Length')
    headers['Cache-Control'] = 'no-cache'
    headers['Content-Type'] = 'text/csv; charset=utf-8'
    headers['Content-Disposition'] = %(attachment; filename="#{filename}")
    headers['X-Accel-Buffering'] = 'no'
    headers['Last-Modified'] = Time.zone.now.ctime.to_s
  end

  def streamable_response_body(export_data:, export_headers:, item_yielder:)
    Enumerator.new do |yielder|
      yielder << SafeCSV.generate_line(export_headers) if export_headers.present?
      export_data.map { |item| yielder << SafeCSV.generate_line(item_yielder.call(item)) }
    end
  end
end

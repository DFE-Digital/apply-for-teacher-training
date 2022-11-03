module StreamableDataExport
  BATCH_SIZE = 300

private

  def set_stream_headers
    headers['Cache-Control'] = 'no-cache'
    headers['X-Accel-Buffering'] = 'no'
    headers['Last-Modified'] = Time.zone.now.ctime.to_s
  end

  def stream_csv(data:, filename:, batch_size: BATCH_SIZE, &block)
    block ||= ->(row) { row }

    set_stream_headers
    send_stream(filename:, type: 'text/csv') do |stream|
      stream.write SafeCSV.generate_line(block.call(data.first).keys)

      row_block = ->(row) { stream.write SafeCSV.generate_line(block.call(row).values) }
      if data.respond_to?(:find_each)
        data.find_each(batch_size:, &row_block)
      else
        data.each(&row_block)
      end
    end
  end
end

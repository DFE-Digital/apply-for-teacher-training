require 'rails_helper'

class TestSubject
  include StreamableDataExport
  attr_accessor :headers, :response
end

RSpec.describe StreamableDataExport do
  subject(:test_subject) do
    ts = TestSubject.new
    ts.headers = { 'Content-Length' => '1024' }
    # Set a response without a status code.
    ts.response = ActionDispatch::Response.new(nil)
    ts
  end

  describe '#streamable_response' do
    let!(:streamed_response) do
      test_subject.streamable_response(
        filename: 'export-data.csv',
        export_headings: %w[=(id) name],
        export_data: [%w[=(1) sue], %w[=(2) helen]],
        item_yielder: proc { |item| ["#{item.first}XX", item.last.capitalize] },
      )
    end

    it 'adds headers suitable for a streamed response' do
      expect(test_subject.headers['Cache-Control']).to eq('no-cache')
      expect(test_subject.headers['Content-Type']).to eq('text/csv; charset=utf-8')
      expect(test_subject.headers['Content-Disposition']).to eq(%(attachment; filename="export-data.csv"))
      expect(test_subject.headers['X-Accel-Buffering']).to eq('no')
      expect(test_subject.headers.keys).to include('Last-Modified')
    end

    it 'removes Content-Length header' do
      expect(test_subject.headers.keys).not_to include('Content-Length')
    end

    it 'sets a response status of 200' do
      expect(test_subject.response.status).to eq(200)
    end

    it 'returns an enumerator' do
      expect(streamed_response).to be_a(Enumerator)
    end

    it 'appends sanitised export headers and rows' do
      expect(streamed_response.next).to eq(".=(id),name\n")
      expect(streamed_response.next).to eq(".=(1)XX,Sue\n")
      expect(streamed_response.next).to eq(".=(2)XX,Helen\n")
    end
  end
end

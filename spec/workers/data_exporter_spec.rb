require 'rails_helper'

RSpec.describe DataExporter, with_audited: true do
  let(:failing_exporter) do
    Class.new do
      def data_for_export
        raise 'the level of debate in this country'
      end
    end
  end

  before do
    stub_const('ExporterThatFails', failing_exporter)
  end

  describe '#perform' do
    it 'adds a comment to the audit log if the export fails' do
      data_export = DataExport.create!

      expect {
        DataExporter.new.perform('ExporterThatFails', data_export.id)
      }.to raise_error('the level of debate in this country')

      expect(data_export.reload.audits.last.comment).to eql('Export generation failed: `the level of debate in this country`')
    end
  end
end

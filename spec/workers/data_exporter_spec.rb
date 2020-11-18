require 'rails_helper'

RSpec.describe DataExporter, with_audited: true do
  # rubocop:disable RSpec/LeakyConstantDeclaration
  class ExporterThatFails
    def data_for_export
      raise 'the level of debate in this country'
    end
  end
  # rubocop:enable RSpec/LeakyConstantDeclaration

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

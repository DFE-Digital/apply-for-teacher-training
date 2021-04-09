require 'rails_helper'

RSpec.describe DataMigrations::BackfillExportType do
  it 'backfills the export_type column in Data Exports' do
    data_export = create(:data_export, name: 'Active provider user permissions', export_type: nil)

    described_class.new.change
    expect(data_export.reload.export_type).to eq 'active_provider_user_permissions'
  end

  it 'correctly backfills for old and renamed exports' do
    work_history_export = create(:data_export, name: 'Unexplained breaks in work history', export_type: nil)
    persona_export = create(:data_export, name: 'Locations', export_type: nil)
    tad_export = create(:data_export, name: 'Applications for TAD', export_type: nil)
    tad_provider_performance_export = create(:data_export, name: 'Provider performance for TAD', export_type: nil)
    candidate_survey_export = create(:data_export, name: 'Candidate survey', export_type: nil)

    described_class.new.change

    expect(work_history_export.reload.export_type).to eq 'work_history_break'
    expect(persona_export.reload.export_type).to eq 'persona_export'
    expect(tad_export.reload.export_type).to eq 'tad_applications'
    expect(tad_provider_performance_export.reload.export_type).to eq 'tad_provider_performance'
    expect(candidate_survey_export.reload.export_type).to eq nil
  end
end

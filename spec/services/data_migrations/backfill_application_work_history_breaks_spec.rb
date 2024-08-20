require 'rails_helper'

RSpec.describe DataMigrations::BackfillApplicationWorkHistoryBreaks do
  it 'backfills application work history breaks with breakable id and type nil' do
    work_history_break = create(
      :application_work_history_break,
      application_form: create(:application_form),
    )

    described_class.new.change

    expect(work_history_break.reload.breakable_id).to eq(work_history_break.application_form_id)
    expect(work_history_break.breakable_type).to eq('ApplicationForm')
  end
end

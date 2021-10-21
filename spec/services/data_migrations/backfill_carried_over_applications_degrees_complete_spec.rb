require 'rails_helper'

RSpec.describe DataMigrations::BackfillCarriedOverApplicationsDegreesComplete do
  let!(:form_with_missing_start_year_degree) do
    form = create(:application_form, degrees_completed: true)
    create(:degree_qualification, application_form: form, start_year: nil)
    form
  end
  let!(:form_with_missing_award_year_degree) do
    form = create(:application_form, degrees_completed: true)
    create(:degree_qualification, application_form: form, award_year: nil)
    form
  end
  let!(:incomplete_form_with_invalid_degree) do
    form = create(:application_form, degrees_completed: false)
    create(:degree_qualification, application_form: form, start_year: nil)
    form
  end
  let!(:submitted_form_with_invalid_degree) do
    form = create(:application_form, degrees_completed: true, submitted_at: 1.day.ago)
    create(:degree_qualification, application_form: form, award_year: nil)
    form
  end
  let!(:form_with_valid_degree) do
    form = create(:application_form, degrees_completed: true)
    create(:degree_qualification, application_form: form)
    form
  end
  let!(:previous_year_form_with_invalid_degree) do
    form = create(:application_form, recruitment_cycle_year: RecruitmentCycle.previous_year, degrees_completed: true)
    create(:degree_qualification, application_form: form, start_year: nil)
    form
  end

  it 'audits any changes made', with_audited: true do
    described_class.new.change
    related_audit = form_with_missing_start_year_degree.audits.last
    expect(related_audit.comment).to eq('Setting degree section to incomplete as candidate needs to enter missing information')
    expect(related_audit.audited_changes.keys).to contain_exactly('degrees_completed')
  end

  it 'sets degrees_complete to false on unsubmitted current cycle applications with degrees with no start_year' do
    expect { described_class.new.change }.to change { form_with_missing_start_year_degree.reload.degrees_completed }.from(true).to(false)
  end

  it 'sets degrees_complete to false on unsubmitted current cycle applications with degrees with no award_year' do
    expect { described_class.new.change }.to change { form_with_missing_award_year_degree.reload.degrees_completed }.from(true).to(false)
  end

  it 'does not change unsubmitted current cycle applications with degrees with no award_year but degrees_complete already false' do
    expect { described_class.new.change }.not_to(change { incomplete_form_with_invalid_degree.reload.updated_at })
  end

  it 'does not change submitted current cycle applications with invalid degrees' do
    expect { described_class.new.change }.not_to(change { submitted_form_with_invalid_degree.reload.updated_at })
  end

  it 'does not change unsubmitted current cycle applications with valid degrees' do
    expect { described_class.new.change }.not_to(change { form_with_valid_degree.reload.updated_at })
  end

  it 'does not change previous cycle applications with invalid degrees' do
    expect { described_class.new.change }.not_to(change { previous_year_form_with_invalid_degree.reload.updated_at })
  end
end

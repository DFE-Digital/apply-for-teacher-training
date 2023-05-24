require 'rails_helper'

RSpec.describe GetUnstartedApplicationsReadyToNudge do
  it 'returns unstarted applications that have been inactive for more than 14 days' do
    application_form = create(:application_form)
    fifteen_days_ago = 15.days.ago
    application_form.update_columns(
      updated_at: fifteen_days_ago,
      created_at: fifteen_days_ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits unstarted applications that have been started (updated since they were created)' do
    application_form = create(:application_form)
    application_form.update_columns(
      updated_at: 15.days.ago,
      created_at: 16.days.ago,
    )

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits unstarted applications that have been inactive for less than 14 days' do
    application_form = create(:application_form)
    thirteen_days_ago = 13.days.ago
    application_form.update_columns(
      updated_at: thirteen_days_ago,
      created_at: thirteen_days_ago,
    )

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits applications that were started in a previous cycle' do
    application_form = create(
      :application_form,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
    )
    fifteen_days_ago = 15.days.ago
    application_form.update_columns(
      updated_at: fifteen_days_ago,
      created_at: fifteen_days_ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that already received this email' do
    application_form = create(:application_form)
    fifteen_days_ago = 15.days.ago
    application_form.update_columns(
      updated_at: fifteen_days_ago,
      created_at: fifteen_days_ago,
    )
    create(
      :email,
      mailer: described_class::MAILER,
      mail_template: described_class::MAIL_TEMPLATE,
      application_form:,
    )

    expect(described_class.new.call).to eq([])
  end
end

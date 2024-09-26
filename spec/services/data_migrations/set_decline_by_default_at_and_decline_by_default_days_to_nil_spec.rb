require 'rails_helper'

RSpec.describe DataMigrations::SetDeclineByDefaultAtAndDeclineByDefaultDaysToNil do
  it 'updates choices where decline_by_default_at is not null' do
    application_choice = create(:application_choice,
                                decline_by_default_at: DateTime.now,
                                decline_by_default_days: nil,
                                application_form: build(:application_form, recruitment_cycle_year: 2024))

    described_class.new.change
    expect(application_choice.reload.decline_by_default_at).to be_nil
  end

  it 'updates choices where decline_by_default_days is not null' do
    application_choice = create(:application_choice,
                                decline_by_default_at: nil,
                                decline_by_default_days: 10,
                                application_form: build(:application_form, recruitment_cycle_year: 2024))

    described_class.new.change

    expect(application_choice.reload.decline_by_default_days).to be_nil
  end

  it 'updates choices where both days and at are not null' do
    application_choice = create(:application_choice,
                                decline_by_default_at: DateTime.now,
                                decline_by_default_days: 10,
                                application_form: build(:application_form, recruitment_cycle_year: 2024))

    described_class.new.change

    application_choice.reload
    expect(application_choice.decline_by_default_days).to be_nil
    expect(application_choice.decline_by_default_at).to be_nil
  end

  it 'updates only 2024 application choices' do
    application_2024 = create(:application_choice, decline_by_default_at: Time.zone.now,
                                                   application_form: build(:application_form, recruitment_cycle_year: 2024))
    application_2023 = create(:application_choice, decline_by_default_at: Time.zone.now,
                                                   application_form: build(:application_form, recruitment_cycle_year: 2023))

    described_class.new.change

    expect(application_2024.reload.decline_by_default_at).to be_nil
    expect(application_2023.reload.decline_by_default_at).not_to be_nil
  end
end

require 'rails_helper'

RSpec.describe DataMigrations::CleanseEocChasersSentData do
  it 'destoys any `eoc_deadline_reminder` chasers sent before 14.55 on the 12/7/2021' do
    application_form = create(:application_form)
    create(:chaser_sent, chaser_type: 'reference_request', chased: application_form, created_at: Time.zone.local(2021, 7, 12, 14, 54))
    create(:chaser_sent, chaser_type: 'eoc_deadline_reminder', chased: application_form)
    create(:chaser_sent, chaser_type: 'eoc_deadline_reminder', chased: application_form, created_at: Time.zone.local(2021, 7, 12, 14, 54))

    described_class.new.change

    expect(ChaserSent.count).to eq 2
  end
end

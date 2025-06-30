require 'rails_helper'

RSpec.describe DataMigrations::BackfillApplicationFormOnPoolInvites do
  it 'add application form to pool invites where one does not exist' do
    application_form = create(:application_form)
    invite_without_application = build(:pool_invite, application_form: nil, candidate: application_form.candidate, recruitment_cycle_year: application_form.recruitment_cycle_year)
    invite_without_application.save(validate: false)

    described_class.new.change

    expect(invite_without_application.reload.application_form).to eq application_form
  end
end

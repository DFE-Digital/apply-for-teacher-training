require 'rails_helper'

RSpec.describe DataMigrations::DowncaseAllReferenceEmailAddresses do
  subject(:data_migration) { described_class.new.change }

  before { create_reference }

  context 'when the references email address contains uppercase letters' do
    it 'updates the email address to downcase' do
      reference = ApplicationReference.last
      data_migration
      expect(reference.reload.email_address).to eq('test@example.com')
    end
  end

  it 'does not update any related application choices' do
    reference = ApplicationReference.last
    application_form = reference.application_form
    updated_at = 3.days.ago
    application_choice = create(:application_choice, application_form:, updated_at:)

    data_migration
    expect(application_choice.updated_at).to be_within(1.second).of(updated_at)
  end

  def create_reference
    application_form = create(:application_form)
    sql = <<~SQL
      INSERT INTO "references" (email_address, application_form_id, updated_at, created_at)
      VALUES ('  TEST@EXAMPLE.COM  ',  #{application_form.id}, NOW(), NOW())
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end
end

require 'rails_helper'

RSpec.describe DataMigrations::PopulateSectionCompletedAts, :with_audited do
  let!(:form) { create(:application_form) }

  context 'when nothing has happened with the boolean' do
    it 'does not populate the timestamp' do
      described_class.new.change
      expect(form.reload.contact_details_completed_at).to be_nil
    end
  end

  context 'when the boolean has been set to true' do
    it 'populates the timestamp' do
      update_time = Time.zone.now
      form.update(contact_details_completed: true)
      advance_time

      form.update_columns(contact_details_completed_at: nil)
      described_class.new.change

      expect(form.reload.contact_details_completed_at.iso8601).to eq(update_time.iso8601)
    end
  end

  context 'when the boolean has been set to false' do
    it 'does not populate the timestamp' do
      form.update(contact_details_completed: false)
      advance_time

      form.update_columns(contact_details_completed_at: nil)
      described_class.new.change

      expect(form.reload.contact_details_completed_at).to be_nil
    end
  end

  context 'when the boolean has been set to true and false several times and left on true' do
    it 'populates the timestamp from the latest true value update' do
      form.update(contact_details_completed: true)
      advance_time

      form.update(contact_details_completed: false)
      advance_time

      update_time = Time.zone.now
      form.update(contact_details_completed: true)
      advance_time

      form.update_columns(contact_details_completed_at: nil)
      described_class.new.change

      expect(form.reload.contact_details_completed_at.iso8601).to eq(update_time.iso8601)
    end
  end

  context 'when the boolean has been set to true and false several times and left on false' do
    it 'populates the timestamp from the latest true value update' do
      form.update(contact_details_completed: true)
      advance_time

      form.update(contact_details_completed: false)
      advance_time

      update_time = Time.zone.now
      form.update(contact_details_completed: true)
      advance_time

      form.update(contact_details_completed: false)
      advance_time

      form.update_columns(contact_details_completed_at: nil)
      described_class.new.change

      expect(form.reload.contact_details_completed_at.iso8601).to eq(update_time.iso8601)
    end
  end
end

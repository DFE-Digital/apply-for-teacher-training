require 'rails_helper'

RSpec.describe ImportReferencesFromCsv do
  let(:application_form) { FactoryBot.create(:completed_application_form, references_count: 0) }
  let(:first_reference) { FactoryBot.create(:reference, :unsubmitted, email_address: 'ab@c.com', application_form: application_form) }
  let(:second_reference) { FactoryBot.create(:reference, :unsubmitted, email_address: 'xy@z.com', application_form: application_form) }

  # Timestamp, Reference ID, Email Address, Your name, Name of the person, Feedback, Confirm
  let(:csv_row) { ['2019', 'id', 'ab@c.com', 'My name', 'Their name', 'Feedback', 'I confirm'] }

  before do
    application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references') }
    csv_row[1] = first_reference.id
  end

  describe 'processing a reference row from CSV' do
    it 'imports valid records from a CSV' do
      outcome = ImportReferencesFromCsv.process_row(csv_row)
      expect(outcome[:referee_email]).to eq(first_reference.email_address)
      expect(outcome[:application_form]).to eq(application_form)
      expect(outcome[:updated]).to be true
      expect(outcome[:errors]).to be_nil

      expect(application_form.application_references.find_by!(email_address: 'ab@c.com').feedback).to eq('Feedback')
      application_form.application_choices.each { |choice| expect(choice.status).to eq('awaiting_references') }
    end

    it 'imports multiple valid references for a single application' do
      ImportReferencesFromCsv.process_row(csv_row)
      csv_row[2] = 'xy@z.com'
      csv_row[5] = 'More feedback'
      csv_row[1] = second_reference.id
      ImportReferencesFromCsv.process_row(csv_row)

      expect(application_form.application_references.find_by!(email_address: 'ab@c.com').feedback).to eq('Feedback')
      expect(application_form.application_references.find_by!(email_address: 'xy@z.com').feedback).to eq('More feedback')
      expect(application_form.reload).to be_application_references_complete
    end

    it 'does not change existing feedback' do
      ImportReferencesFromCsv.process_row(csv_row)

      csv_row[5] = 'Edited feedback'
      outcome = ImportReferencesFromCsv.process_row(csv_row)
      expect(outcome[:referee_email]).to eq(csv_row[2])
      expect(outcome[:application_form]).to eq(application_form)
      expect(outcome[:updated]).to be false
      expect(outcome[:errors]).to eq(['Reference already has feedback'])

      expect(application_form.application_references.find_by!(email_address: 'ab@c.com').feedback).to eq('Feedback')
    end

    it 'does not update if an application form is not found' do
      csv_row[1] = 'not_an_id'
      outcome = ImportReferencesFromCsv.process_row(csv_row)

      expect(outcome[:referee_email]).to eq(csv_row[2])
      expect(outcome[:application_form]).to be_nil
      expect(outcome[:updated]).to be false
      expect(outcome[:errors]).to eq(["No application found for reference with ID 'not_an_id'"])
    end

    it 'does not update if the reference email is not associated with the application form' do
      csv_row[2] = 'not_a_valid_email@email.com'
      outcome = ImportReferencesFromCsv.process_row(csv_row)

      expect(outcome[:referee_email]).to eq(csv_row[2])
      expect(outcome[:application_form]).to eq(application_form)
      expect(outcome[:updated]).to eq(false)
      expect(outcome[:errors]).to eq(['Referee email does not match any of the provided referees'])
    end
  end
end

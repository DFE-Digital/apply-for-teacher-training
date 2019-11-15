require 'csv'

class ImportReferencesFromCsv
  def self.call(csv_file:)
    outcomes = []
    CSV.foreach(csv_file) do |row|
      # First column in the headers row of an exported Google Form is always Timestamp
      next if row[0] == 'Timestamp'

      outcomes << process_row(row)
    end

    outcomes
  end

  def self.process_row(row)
    referee_email    = row[2]
    referee_feedback = row[5]
    reference_id     = row[1]

    reference = Reference.find(reference_id)
    application_form = ApplicationForm.includes(:references).where(references: { id: reference_id }).first

    if reference.feedback?
      {
        referee_email: referee_email,
        application_form: application_form,
        updated: false,
        errors: ['Reference already has feedback'],
      }
    else
      import_reference(application_form, referee_email, referee_feedback)
    end
  rescue ActiveRecord::RecordNotFound
    {
      referee_email: referee_email,
      application_form: nil,
      updated: false,
      errors: ["No application found for reference with ID '#{reference_id}'"],
    }
  end

  def self.import_reference(application_form, referee_email, referee_feedback)
    receive_reference = ReceiveReference.new(
      application_form: application_form,
      referee_email: referee_email,
      feedback: referee_feedback,
    )

    updated = receive_reference.save

    {
      referee_email: referee_email,
      application_form: application_form,
      updated: updated,
      errors: updated ? nil : receive_reference.errors.full_messages,
    }
  end
end

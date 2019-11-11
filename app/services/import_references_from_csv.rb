require 'csv'

class ImportReferencesFromCsv
  def self.call
    outcomes = []
    CSV.foreach('references.csv') do |row|
      # First column in the headers row of an exported Google Form is always Timestamp
      next if row[0] == 'Timestamp'

      outcomes << process_row(row)
    end

    outcomes
  end

  def self.process_row(row)
    referee_email    = row[1]
    referee_feedback = row[4]
    application_id   = row[6]

    # TODO: Use support_reference rather than ID?
    application_form = ApplicationForm.find(application_id)

    if reference_has_feedback_already?(application_form, referee_email)
      {
        application_id: application_id,
        updated: false,
        errors: ['Reference already has feedback'],
      }
    else
      import_reference(application_form, referee_email, referee_feedback)
    end
  rescue ActiveRecord::RecordNotFound
    {
      application_id: application_id,
      updated: false,
      errors: ["No application found with ID '#{application_id}'"],
    }
  end

  def self.reference_has_feedback_already?(application_form, referee_email)
    reference = application_form.references.find_by(email_address: referee_email)
    reference && reference.feedback
  end

  def self.import_reference(application_form, referee_email, feedback)
    reference = ReceiveReference.new(
      application_form: application_form,
      referee_email: referee_email,
      reference: feedback,
    )

    updated = !!reference.save

    {
      application_id: application_form.id,
      updated: updated,
      errors: updated ? nil : reference.errors.full_messages,
    }
  end
end

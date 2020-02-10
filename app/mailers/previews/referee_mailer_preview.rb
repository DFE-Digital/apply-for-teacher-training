class RefereeMailerPreview < ActionMailer::Preview
  def reference_request_email
    preview_with_rollback do
      application_form = FactoryBot.create(:application_form, first_name: 'Jane', last_name: 'Smith')
      reference = FactoryBot.create(:reference, application_form: application_form)

      RefereeMailer.reference_request_email(application_form, reference)
    end
  end

  def reference_request_chaser_email
    preview_with_rollback do
      application_form = FactoryBot.create(:application_form, first_name: 'Jane', last_name: 'Smith')
      reference = FactoryBot.create(:reference, application_form: application_form)

      RefereeMailer.reference_request_chaser_email(application_form, reference)
    end
  end

  def survey_email
    application_form = FactoryBot.build_stubbed(:application_form, first_name: 'Rachael')
    reference = FactoryBot.build_stubbed(:reference, application_form: application_form)

    RefereeMailer.survey_email(application_form, reference)
  end

  def survey_chaser_email
    application_form = FactoryBot.build_stubbed(:application_form, first_name: 'Rachael')
    reference = FactoryBot.build_stubbed(:reference, application_form: application_form)

    RefereeMailer.survey_chaser_email(reference)
  end

private

  def preview_with_rollback &block
    mail = nil
    ApplicationForm.transaction do
      mail = block.call
      raise ActiveRecord::Rollback, "we don't want to be committing these on QA"
    end
    mail
  end
end

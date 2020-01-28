class GetRefereesToChase
  def perform
    application_choices = ApplicationChoice.awaiting_references

    application_forms = application_choices.select do |application_choice|
      application_choice.application_form.submitted_at < Time.now - 5.days
    end.map(&:application_form).uniq

    references = application_forms.map(&:application_references).flatten

    references_to_contact = references.select { |reference| reference.feedback_requested? }
  end
end 

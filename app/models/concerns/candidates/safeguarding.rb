module Candidates::Safeguarding
  extend ActiveSupport::Concern

  class_methods do
    def with_safeguarding_concerns
      safeguarding_on_application_forms = joins(:application_forms).where(application_forms: { safeguarding_issues_status: :has_safeguarding_issues_to_declare })
      safeguarding_on_references = joins(application_forms: :application_references).where(application_references: { safeguarding_concerns_status: :has_safeguarding_concerns_to_declare })
      safeguarding_on_rejection_reasons = joins(:application_choices).where(
        "application_choices.structured_rejection_reasons->'selected_reasons' @> '[{\"id\":\"safeguarding\"}]'::jsonb",
      )

      with(
        safeguarding_on_application_forms: safeguarding_on_application_forms,
        safeguarding_on_references: safeguarding_on_references,
        safeguarding_on_rejection_reasons: safeguarding_on_rejection_reasons,
      ).where(id: safeguarding_on_application_forms.select('candidates.id'))
         .or(where(id: safeguarding_on_references.select('candidates.id')))
         .or(where(id: safeguarding_on_rejection_reasons.select('candidates.id')))
    end

    def without_safeguarding_concerns
      where.not(id: with_safeguarding_concerns)
    end
  end

  included do
    def safeguarding_concerns?
      @has_safeguarding_concerns ||= application_forms_with_safeguarding_concerns? || application_references_with_safeguarding_concerns? || application_choices_rejected_with_safeguarding_concerns?
    end

    def application_forms_with_safeguarding_concerns?
      application_forms.exists?(safeguarding_issues_status: :has_safeguarding_issues_to_declare)
    end

    def application_references_with_safeguarding_concerns?
      application_references.exists?(safeguarding_concerns_status: :has_safeguarding_concerns_to_declare)
    end

    def application_choices_rejected_with_safeguarding_concerns?
      application_choices.where(
        <<~SQL,
          application_choices.structured_rejection_reasons->'selected_reasons' @> '[{"id":"safeguarding"}]'::jsonb
        SQL
      ).exists?
    end
  end
end

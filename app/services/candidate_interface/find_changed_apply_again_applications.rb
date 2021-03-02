module CandidateInterface
  class FindChangedApplyAgainApplications
    def call
      apply_again_forms.find_each.lazy.select do |application_form|
        changed?(application_form)
      end
    end

  private

    def apply_again_forms
      ApplicationForm
        .where(
          phase: 'apply_2',
          recruitment_cycle_year: RecruitmentCycle.current_year,
        )
        .includes(previous_application_form: [:application_qualifications], application_qualifications: [])
    end

    def changed?(application_form)
      personal_statement_changed?(application_form) ||
        subject_knowledge_changed?(application_form) ||
        qualifications_changed?(application_form)
    end

    def subject_knowledge_changed?(application_form)
      application_form.subject_knowledge != application_form.previous_application_form.subject_knowledge
    end

    def personal_statement_changed?(application_form)
      application_form.becoming_a_teacher != application_form.previous_application_form.becoming_a_teacher
    end

    def qualifications_changed?(application_form)
      original_qualifications = application_form.previous_application_form.application_qualifications.order(:id)
      new_qualifications = application_form.application_qualifications.order(:id)
      return true if original_qualifications.size != new_qualifications.size

      original_qualifications.any? { |qualification| any_qualification_differ?(qualification, new_qualifications) }
    end

    def any_qualification_differ?(original_qualification, new_qualifications)
      new_qualifications.all? { |new_qualification| !qualifications_match?(original_qualification, new_qualification) }
    end

    IGNORED_QUALIFICATION_ATTRIBUTES = DuplicateApplication::IGNORED_ATTRIBUTES + %i[application_form_id public_id]

    def qualifications_match?(original_qualification, new_qualifications)
      original_attributes = original_qualification.attributes.reject { |k, _| IGNORED_QUALIFICATION_ATTRIBUTES.include?(k) }
      new_attributes = new_qualifications.attributes.reject { |k, _| IGNORED_QUALIFICATION_ATTRIBUTES.include?(k) }
      original_attributes == new_attributes
    end
  end
end

module CandidateInterface
  class FindChangedApplyAgainApplications
    def all_forms
      apply_again_forms
    end

    def changed_forms
      apply_again_forms.find_each.lazy.select do |application_form|
        changed?(application_form)
      end
    end

    def all_candidate_count
      all_forms.map(&:candidate_id).uniq.count
    end

    def changed_candidate_count
      changed_forms.map(&:candidate_id).uniq.count
    end

  private

    def apply_again_forms
      ApplicationForm
        .where(
          phase: 'apply_2',
          recruitment_cycle_year: RecruitmentCycle.current_year,
        )
        .includes(:application_qualifications, previous_application_form: [:application_qualifications])
    end

    def changed?(application_form)
      significant_values(application_form) !=
        significant_values(application_form.previous_application_form)
    end

    def significant_values(application_form)
      application_form.as_json(
        only: %i[becoming_a_teacher subject_knowledge],
        include: {
          application_qualifications: {
            except: DuplicateApplication::IGNORED_CHILD_ATTRIBUTES,
          },
        },
      )
    end
  end
end

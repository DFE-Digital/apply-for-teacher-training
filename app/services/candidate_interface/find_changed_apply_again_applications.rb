module CandidateInterface
  class FindChangedApplyAgainApplications
    def all_forms(start_time, end_time)
      apply_again_forms(start_time, end_time)
    end

    def changed_forms(start_time, end_time)
      apply_again_forms(start_time, end_time).find_each.lazy.select do |application_form|
        changed?(application_form)
      end
    end

    def all_candidate_count(
      start_time = CycleTimetable.apply_reopens.beginning_of_day,
      end_time = Time.zone.now.end_of_day
    )
      all_forms(start_time, end_time).select(:candidate_id).distinct.count
    end

    def changed_candidate_count(
      start_time = CycleTimetable.apply_reopens.beginning_of_day,
      end_time = Time.zone.now.end_of_day
    )
      changed_forms(start_time, end_time).map(&:candidate_id).uniq.count
    end

  private

    def apply_again_forms(start_time, end_time)
      ApplicationForm
        .where(
          phase: 'apply_2',
          recruitment_cycle_year: RecruitmentCycle.current_year,
        )
        .where(
          'submitted_at BETWEEN ? AND ?',
          start_time,
          end_time,
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

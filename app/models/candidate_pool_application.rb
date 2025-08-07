class CandidatePoolApplication < ApplicationRecord
  belongs_to :application_form
  belongs_to :candidate

  def self.filtered_application_forms(filters, provider_user = nil)
    scope = CandidatePoolApplication.all
    scope = filter_by_candidate_id(scope, filters)
    scope = remove_application_forms_rejected_by_providers(scope, provider_user)
    scope = filter_by_subject(scope, filters)
    scope = filter_by_study_mode(scope, filters)
    scope = filter_by_course_type(scope, filters)
    scope = filter_by_needs_visa(scope, filters)
    scope = filter_by_funding_type(scope, filters)

    ApplicationForm.where(id: scope.select(:application_form_id))
  end

  def self.remove_application_forms_rejected_by_providers(scope, provider_user)
    return scope if provider_user.blank?

    provider_ids = provider_user.providers.ids
    rejected_application_ids = where('rejected_provider_ids @> ARRAY[?]::bigint[]', Array.wrap(provider_ids)).select(:application_form_id)

    scope.where.not(application_form_id: rejected_application_ids)
  end

  def self.filter_by_candidate_id(scope, filters)
    return scope if filters[:candidate_id].blank?

    scope.where(candidate_id: filters[:candidate_id])
  end

  def self.filter_by_subject(scope, filters)
    return scope if filters[:subject_ids].blank?

    scope.where('subject_ids && ARRAY[:subject_ids]::bigint[]', subject_ids: filters[:subject_ids])
  end

  def self.filter_by_study_mode(scope, filters)
    return scope if filters[:study_mode].blank?
    return scope if filters[:study_mode].sort == %w[full_time part_time].sort

    attributes = {}
    if filters[:study_mode].include?('full_time')
      attributes = { study_mode_full_time: true }
    end

    if filters[:study_mode].include?('part_time')
      attributes = { study_mode_part_time: true }
    end

    scope.where(attributes)
  end

  def self.filter_by_course_type(scope, filters)
    return scope if filters[:course_type].blank?
    return scope if filters[:course_type].sort == %w[undergraduate postgraduate].sort

    attributes = {}
    if filters[:course_type].include?('undergraduate')
      attributes = { course_type_undergraduate: true }
    end

    if filters[:course_type].include?('postgraduate')
      attributes = { course_type_postgraduate: true }
    end

    scope.where(attributes)
  end

  def self.filter_by_needs_visa(scope, filters)
    return scope if filters[:visa_sponsorship].blank?
    return scope if filters[:visa_sponsorship].sort == ['required', 'not required'].sort

    attributes = {}
    if filters[:visa_sponsorship].include?('required')
      attributes = { needs_visa: true }
    end

    if filters[:visa_sponsorship].include?('not required')
      attributes = { needs_visa: false }
    end

    scope.where(attributes)
  end

  def self.filter_by_funding_type(scope, filters)
    return scope if filters[:funding_type].blank?

    if filters[:funding_type].include?('fee')
      scope.where(course_funding_type_fee: true)
    end
  end

  def self.closed?
    timetable = RecruitmentCycleTimetable.current_timetable
    timetable.after_apply_deadline? || Time.zone.now.before?(open_at)
  end

  def self.open_at
    timetable = RecruitmentCycleTimetable.current_timetable

    CandidateInterface::InactiveDateCalculator.new(
      effective_date: timetable.apply_opens_at,
    ).inactive_date
  end
end

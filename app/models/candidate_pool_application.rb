class CandidatePoolApplication < ApplicationRecord
  belongs_to :application_form
  belongs_to :candidate

  def self.filtered_application_forms(filters)
    scope = CandidatePoolApplication.all
    scope = filter_by_subject(scope, filters)
    scope = filter_by_study_mode(scope, filters)
    scope = filter_by_course_type(scope, filters)
    scope = filter_by_needs_visa(scope, filters)

    ApplicationForm.where(id: scope.select(:application_form_id))
  end

  def self.filter_by_subject(scope, filters)
    return scope if filters[:subject].blank?

    scope.where('subject_ids && ARRAY[:subject_ids]::bigint[]', subject_ids: filters[:subject])
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
end

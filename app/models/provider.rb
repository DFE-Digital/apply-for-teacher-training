class Provider < ApplicationRecord
  belongs_to :vendor, optional: true
  has_many :courses
  has_many :sites
  has_many :course_options, through: :courses
  has_many :application_choices, through: :course_options
  has_many :application_forms, through: :application_choices
  has_many :application_references, through: :application_forms
  has_many :accredited_courses, class_name: 'Course', inverse_of: :accredited_provider, foreign_key: :accredited_provider_id

  has_many :provider_permissions, dependent: :destroy
  has_many :provider_users, through: :provider_permissions
  has_many :training_provider_permissions, class_name: 'ProviderRelationshipPermissions', foreign_key: :training_provider_id
  has_many :ratifying_provider_permissions, class_name: 'ProviderRelationshipPermissions', foreign_key: :ratifying_provider_id
  has_many :provider_agreements
  has_many :vendor_api_requests
  has_many :vendor_api_tokens

  has_many :performance_reports, class_name: 'Publications::ProviderRecruitmentPerformanceReport'

  enum :region_code, {
    east_midlands: 'east_midlands',
    eastern: 'eastern',
    london: 'london',
    no_region: 'no_region',
    north_east: 'north_east',
    north_west: 'north_west',
    scotland: 'scotland',
    south_east: 'south_east',
    south_west: 'south_west',
    wales: 'wales',
    west_midlands: 'west_midlands',
    yorkshire_and_the_humber: 'yorkshire_and_the_humber',
  }

  enum :provider_type, {
    lead_school: 'lead_school',
    scitt: 'scitt',
    university: 'university',
  }

  audited
  has_associated_audits

  delegate :name, to: :vendor, prefix: true, allow_nil: true

  def self.with_courses
    includes(:courses).where.not(courses: { id: nil })
  end

  def name_and_code
    "#{name} (#{code})"
  end

  def accredited_courses
    Course.where(accredited_provider: self)
  end

  def application_forms
    ApplicationForm.where(id: application_choices.select(:application_form_id))
  end

  def onboarded?
    provider_agreements.any?
  end

  def selectable_school?
    return true unless current_year >= 2025

    super
  end

  def current_year
    if CycleTimetable.use_database_timetables?
      RecruitmentCycleTimetable.real_current_year
    else
      CycleTimetable.current_year
    end
  end

  def lacks_admin_users?
    courses.any? &&
      !(provider_permissions.exists?(manage_users: true) &&
        provider_permissions.exists?(manage_organisations: true))
  end

  def geocoded?
    latitude.present? && longitude.present?
  end
end

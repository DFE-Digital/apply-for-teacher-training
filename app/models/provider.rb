class Provider < ApplicationRecord
  has_many :courses
  has_many :sites
  has_many :course_options, through: :courses
  has_many :application_choices, through: :course_options
  has_many :accredited_courses, class_name: 'Course', inverse_of: :accredited_provider, foreign_key: :accredited_provider_id

  has_many :provider_permissions, dependent: :destroy
  has_many :provider_users, through: :provider_permissions
  has_many :provider_agreements

  enum region_code: {
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

  audited

  scope :manageable_by, ->(provider_user) do
    joins(:provider_permissions)
      .where(ProviderPermissions.table_name => { provider_user_id: provider_user.id, manage_users: true })
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

  def all_associated_accredited_providers_onboarded?
    accredited_providers = courses.map(&:accredited_provider).uniq.compact
    accredited_providers.all?(&:onboarded?)
  end
end

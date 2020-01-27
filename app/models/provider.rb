class Provider < ApplicationRecord
  has_many :courses
  has_many :sites
  has_many :course_options, through: :courses
  has_many :application_choices, through: :course_options

  has_many :provider_users_providers, dependent: :destroy
  has_many :provider_users, through: :provider_users_providers
  has_many :provider_agreements

  def name_and_code
    "#{name} (#{code})"
  end

  def accredited_courses
    Course.where(accrediting_provider: self)
  end
end

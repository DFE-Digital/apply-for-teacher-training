class SiteSetting < ApplicationRecord
  audited

  validates :name, uniqueness: true

  def self.cycle_schedule
    find_or_create_by!(name: 'cycle_schedule').value&.to_sym || :real
  end

  def self.continuous_application_year
    find_or_create_by!(name: 'continuous_application_year').value&.to_sym || RecruitmentCycle::CONTINUOUS_APPLICATIONS_CYCLE_YEAR
  end

  def self.set(name:, value:)
    find_or_create_by!(name:).update!(value:)
  end
end

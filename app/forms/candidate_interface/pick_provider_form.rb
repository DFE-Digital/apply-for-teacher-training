module CandidateInterface
  class PickProviderForm
    include ActiveModel::Model

    attr_accessor :provider_id
    validates :provider_id, presence: true

    def available_providers
      @available_providers ||= Provider
      .joins(:courses)
      .where(courses: { recruitment_cycle_year: RecruitmentCycle.current_year, exposed_in_find: true })
      .where('courses.applications_open_from <= ?', Time.zone.today)
      .order(:name)
      .distinct
    end
  end
end

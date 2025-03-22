module CandidateInterface
  class PickProviderForm
    include ActiveModel::Model

    attr_accessor :provider_id
    validates :provider_id, presence: true

    def available_providers
      @available_providers ||= Provider
      .joins(:courses)
      .where(courses: { recruitment_cycle_year:, exposed_in_find: true })
      .order(:name)
      .distinct
    end

    def recruitment_cycle_year
      @recruitment_cycle_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end

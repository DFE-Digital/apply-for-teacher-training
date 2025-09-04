class DeferredOfferConfirmation < ApplicationRecord
  class CourseForm < DeferredOfferConfirmation
    validates :course_id, presence: true

    def courses_for_select
      offer.provider.courses
           .where(recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
           .includes(:provider, :accredited_provider)
           .order(:name)
    end
  end

  belongs_to :provider_user
  belongs_to :offer
  belongs_to :course, optional: true
  belongs_to :location, optional: true, class_name: 'Site', foreign_key: 'site_id'

  enum :study_mode, { full_time: 'full_time', part_time: 'part_time' },
       validate: { allow_nil: true },
       instance_methods: false,
       scopes: false

  enum :conditions_status, { met: 'met', pending: 'pending' },
       validate: { allow_nil: true },
       instance_methods: false,
       scopes: false

  delegate :application_choice, :conditions, :provider, to: :offer
  delegate :name_and_code, to: :provider, prefix: true, allow_nil: true
  delegate :name_and_code, to: :course, prefix: true, allow_nil: true
  delegate :name_and_address, to: :location, prefix: true, allow_nil: true

  def study_mode_humanized
    study_mode&.humanize
  end
end

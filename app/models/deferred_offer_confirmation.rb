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

  class ConditionsForm < DeferredOfferConfirmation
    validates :conditions_status, presence: true

    def offer_conditions_status
      offer&.all_conditions_met? ? :met : :pending
    end
  end

  class StudyModeForm < DeferredOfferConfirmation
    SelectOption = Data.define(:id, :name)

    validates :study_mode, presence: true

    enum :study_mode, { full_time: 'full_time', part_time: 'part_time' },
         validate: { allow_nil: false },
         instance_methods: false,
         scopes: false

    def study_modes_for_select
      StudyModeForm.study_modes.map { |id, value| SelectOption.new(id: id, name: value.humanize) }
    end
  end

  class LocationForm < DeferredOfferConfirmation
    validates :site_id, presence: true
    validate :no_raw_input

    attr_accessor :site_id_raw

    def locations_for_select
      provider_sites = offer.provider.sites.order(:name)

      if provider_sites.count > 20
        provider_sites.map { |site| ["#{site.name} - #{site.full_address}", site.id] }.unshift([nil, nil])
      else
        provider_sites
      end
    end

  private

    def no_raw_input
      return if locations_for_select.count <= 20
      return if site_id.blank?
      return if locations_for_select.any? do |name, id|
        site_id_raw == name && id == site_id.to_i
      end

      errors.add(:site_id, :blank)
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

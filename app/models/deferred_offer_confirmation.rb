class DeferredOfferConfirmation < ApplicationRecord
  class CourseForm < DeferredOfferConfirmation
    attr_accessor :course_id_raw
    validate :no_raw_input

    validates :course_id, presence: true

    def courses_for_select
      @courses_for_select ||= offer.provider.courses
           .where(recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
           .includes(:provider, :accredited_provider)
           .order(:name)
    end

    def default_value_for_select
      return course_id_raw if course_id_raw.present?

      course_available_for_select? ? (course_id_raw || course_id) : nil
    end

    def course_available_for_select?
      courses_for_select.exists?(id: course_id)
    end

  private

    def no_raw_input
      return if courses_for_select.size < 20
      return if course_id.blank?

      selected_course = courses_for_select.find_by(id: course_id)
      return if selected_course && selected_course.name_and_code == course_id_raw

      errors.add(:course_id, :blank)
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
      course_study_modes.map { |course_study_mode| SelectOption.new(id: course_study_mode, name: course_study_mode.humanize) }
    end
  end

  class LocationForm < DeferredOfferConfirmation
    attr_accessor :site_id_raw
    validate :no_raw_input

    validates :site_id, presence: true

    def locations_for_select
      course_sites.distinct.order(:name)
    end

    def default_value_for_select
      return site_id_raw if site_id_raw.present?

      location_available_for_select? ? (site_id_raw || site_id) : nil
    end

    def location_available_for_select?
      locations_for_select.exists?(id: site_id)
    end

  private

    def no_raw_input
      return if locations_for_select.size < 20
      return if site_id.blank?

      selected_location = locations_for_select.find_by(id: site_id)
      return if selected_location && selected_location.name_and_address == site_id_raw

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
  delegate :site, :study_mode, :course, to: :offer, prefix: true
  delegate :study_modes, :sites, to: :course, prefix: true

  validate :course_option_available, on: :submit
  validates :course, presence: { on: :submit }
  validates :location, presence: { on: :submit }
  validates :study_mode, presence: { on: :submit }

  after_initialize do
    if course_id.nil? && site_id.nil? && study_mode.nil?
      self.course_id ||= offer.course.id
      self.site_id ||= offer.site.id
      self.study_mode ||= offer.study_mode
    end
  end

  before_save do
    next if course.blank?

    self.location = nil unless location_in_cycle?
    self.study_mode = nil unless study_mode_in_cycle?
  end

  def study_mode_humanized
    study_mode&.humanize
  end

private

  def course_option_available
    if course_id.present? && !course_in_cycle?
      errors.add(:course, :not_in_cycle)
    end

    if site_id.present? && !location_in_cycle?
      errors.add(:location, :not_available_for_course)
    end

    if study_mode.present? && !study_mode_in_cycle?
      errors.add(:study_mode, :not_available_for_course)
    end
  end

  def course_in_cycle?
    return false if course_id.nil?

    validating_course.present?
  end

  def location_in_cycle?
    return false if site_id.nil? || validating_course.nil?

    validating_course.sites.exists?(code: location.code)
  end

  def study_mode_in_cycle?
    return false if study_mode.nil? || validating_course.nil?

    validating_course.course_options.exists?(study_mode: study_mode)
  end

  def validating_course
    return @validating_course if defined?(@validating_course)

    @validating_course = provider.courses.current_cycle.find_by(code: course.code)
  end
end

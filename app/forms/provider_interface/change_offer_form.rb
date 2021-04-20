module ProviderInterface
  class ChangeOfferForm
    include ActiveModel::Model
    attr_accessor :application_choice, :step, :provider_id, :course_id, :study_mode, :course_option_id, :entry

    validates :application_choice, presence: true

    # This is a form for a multi-step process, in which each step depends on the previous ones.
    # Validation needs to take this into account, e.g. it is fine for course_id to be blank if step == :provider
    #
    STEPS = %i[provider course study_mode course_option confirm update].freeze
    validates :step, presence: true, inclusion: { in: STEPS, message: '%{value} is not a valid step' }

    def step_after?(step_symbol)
      STEPS.index(step) > STEPS.index(step_symbol) if step
    end

    def previous_step
      idx = STEPS.index(step)
      if idx&.positive?
        STEPS[idx - 1]
      else
        STEPS[0]
      end
    end

    def next_step
      idx = STEPS.index(step)
      if idx && idx < (STEPS.count - 1)
        STEPS[idx + 1]
      else
        STEPS[(STEPS.count - 1)]
      end
    end

    validates_each :provider_id do |record, attr, value|
      record.errors.add attr, :blank if record.step_after?(:provider) && value.blank?
    end

    validates_each :course_id do |record, attr, value|
      if record.step_after?(:course)
        record.errors.add attr, :blank if value.blank? || !course_matches_provider?(record)
        record.errors.add attr, :not_open_on_apply if value.present? && !course_open_on_apply?(record)
      end
    end

    VALID_STUDY_MODES = %w[full_time part_time].freeze

    validates_each :study_mode do |record, attr, value|
      if record.step_after?(:study_mode)
        record.errors.add attr, :blank if value.blank?
        record.errors.add attr, :unsupported if value.present? && !VALID_STUDY_MODES.include?(value)
        record.errors.add attr, :unavailable_for_course if value.present? && !study_mode_valid_for_course?(record)
        record.errors.add attr, :no_course_options if value.present? && !study_mode_with_options?(record)
      end
    end

    validates_each :course_option_id do |record, attr, value|
      if record.step_after?(:course_option)
        record.errors.add attr, :blank if value.blank? || !course_option_matches_course?(record)
      end
    end

    def self.course_matches_provider?(record)
      course = Course.find(record.course_id) if record.course_id
      course && record.provider_id && course.provider.id == record.provider_id
    end

    def self.course_open_on_apply?(record)
      course = Course.find(record.course_id)
      course.open_on_apply
    end

    def self.course_option_matches_course?(record)
      record.course_option_id && CourseOption.find(record.course_option_id).course.id == record.course_id
    end

    def self.study_mode_valid_for_course?(record)
      if record.course_id
        course = Course.find(record.course_id)
        course.supports_study_mode? record.study_mode
      end
    end

    def self.study_mode_with_options?(record)
      CourseOption.where(course_id: record.course_id, study_mode: record.study_mode).present?
    end

    def new_offer?
      application_choice.offer.blank?
    end

    def selected_course_option
      if course_option_id.present?
        CourseOption.find(course_option_id)
      end
    end
  end
end

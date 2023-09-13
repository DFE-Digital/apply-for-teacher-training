module CandidateInterface
  class PickSiteForm
    include ActiveModel::Model

    attr_accessor :application_form, :course_option_id
    validates :course_option_id, presence: true
    validate :number_of_choices, on: :save

    def self.available_sites(course_id, study_mode)
      CourseOption
        .available
        .includes(:site)
        .where(course_id:)
        .where(study_mode:)
        .sort_by { |course_option| course_option.site.name }
    end

    def save
      return unless valid?(:save)

      application_form.application_choices.new.configure_initial_course_choice!(course_option)
    end

    def update(application_choice)
      return unless valid?

      application_choice.configure_initial_course_choice!(course_option)
    end

  private

    def course_option
      @course_option ||= CourseOption.find(course_option_id)
    end

    def number_of_choices
      return if application_form.can_add_more_choices?

      error_key = 'errors.messages.too_many_course_choices'

      errors.add(:base, I18n.t!(error_key, max_applications: ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES, course_name: course_option.course.name_and_code))
    end
  end
end

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
        .where(course_id: course_id)
        .where(study_mode: study_mode)
        .sort_by { |course_option| course_option.site.name }
    end

    def save
      return unless valid?(:save)

      application_form.application_choices.create!(
        course_option: course_option,
        current_course_option_id: course_option.id,
      )
    end

    def update(application_choice)
      return unless valid?

      application_choice.update!(
        course_option: course_option,
        current_course_option_id: course_option.id,
      )
    end

  private

    def course_option
      @course_option ||= CourseOption.find(course_option_id)
    end

    def number_of_choices
      return if application_form.can_add_more_choices?

      error_key = if application_form.candidate_can_choose_single_course?
                    'errors.messages.apply_again_course_already_chosen'
                  else
                    'errors.messages.too_many_course_choices'
                  end

      errors.add(:base, I18n.t!(error_key, course_name_and_code: course_option.course.name_and_code))
    end
  end
end

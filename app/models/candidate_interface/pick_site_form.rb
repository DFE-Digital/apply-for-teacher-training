module CandidateInterface
  class PickSiteForm
    include ActiveModel::Model

    attr_accessor :application_form, :provider_id, :course_id, :study_mode, :course_option_id
    validates :course_option_id, presence: true
    validate :candidate_can_only_apply_to_3_courses

    def available_sites
      relation = CourseOption.includes(:site).where(course_id: course.id)

      if FeatureFlag.active?('choose_study_mode')
        relation = relation.where(study_mode: study_mode)
      end

      relation.sort_by { |course_option| course_option.site.name }
    end

    def save
      return unless valid?

      application_form.application_choices.create!(
        course_option: course_option,
      )
    end

  private

    def course_option
      CourseOption.find(course_option_id)
    end

    def course
      @course ||= provider.courses.find(course_id)
    end

    def provider
      @provider ||= Provider.find(provider_id)
    end

    def candidate_can_only_apply_to_3_courses
      return if application_form.application_choices.count <= 2

      errors[:base] << 'You can only apply for up to 3 courses'
    end
  end
end

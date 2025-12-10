module SupportInterface
  module ApplicationForms
    class ChangeCourseChoiceForm
      include ActiveModel::Model

      attr_accessor :application_choice_id,
                    :application_choice,
                    :provider_code,
                    :course_code,
                    :study_mode,
                    :site_code,
                    :accept_guidance,
                    :audit_comment_ticket,
                    :confirm_course_change,
                    :checkbox_rendered
      attr_writer :recruitment_cycle_year

      validates :provider_code, :course_code, :study_mode, :site_code, :accept_guidance, :audit_comment_ticket, presence: true
      validates :confirm_course_change, presence: true, if: :checkbox_rendered?

      validate :provider_exists
      validate :course_exists, if: :provider_present?
      validate :study_mode_exists, if: :course_present?
      validate :site_exists, if: :course_present?

      delegate :present?, to: :provider, prefix: true
      delegate :present?, to: :course, prefix: true
      delegate :present?, to: :course_option, prefix: true

      validates_with ZendeskUrlValidator

      def save(application_choice)
        @application_choice = application_choice
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        return false unless valid?

        if offer_has_ske_conditions?
          remove_ske_conditions!
        end

        SupportInterface::ChangeApplicationChoiceCourseOption.new(
          application_choice_id: application_choice,
          provider_id: provider.id,
          course_code:,
          study_mode:,
          site_code:,
          audit_comment: audit_comment_ticket,
          confirm_course_change:,
          recruitment_cycle_year:,
        ).call
      rescue ActiveRecord::RecordNotFound
        raise CourseChoiceError, 'This is not a valid course option'
      rescue ActiveRecord::RecordInvalid
        raise CourseChoiceError, 'This course option has already been taken'
      end

      def provider_exists
        errors.add(:provider_code, :invalid_provider_code) if provider.blank?
      end

      def course_exists
        return if course.present?

        if provider.courses.find_by(code: course_code).present?
          errors.add(:course_code, :invalid_course_code_for_recruitment_cycle)
        else
          errors.add(:course_code, :invalid_course_code)
        end
      end

      def study_mode_exists
        return if course_option.present?

        if site.present?
          errors.add(:study_mode, :invalid_study_mode_for_site)
        elsif option_study_mode.blank?
          errors.add(:study_mode, :invalid_study_mode)
        end
      end

      def site_exists
        return if course_option.present?

        if option_study_mode.present?
          errors.add(:site_code, :invalid_site_code_for_study_mode)
        elsif site.blank?
          errors.add(:site_code, :invalid_site_code)
        end
      end

      def checkbox_rendered?
        checkbox_rendered == 'true'
      end

      def application_choice_with_offer
        ApplicationChoice.find(application_choice).offer
      end

      def offer_has_ske_conditions?
        application_choice_with_offer&.ske_conditions.present?
      end

      def remove_ske_conditions!
        RemoveSkeConditionsFromOffer.new(offer: application_choice_with_offer).call
      end

      def recruitment_cycle_year
        @recruitment_cycle_year || RecruitmentCycleTimetable.current_year
      end

    private

      def provider
        return @provider if defined?(@provider)

        @provider = Provider.find_by(code: provider_code)
      end

      def course
        return if provider.blank?

        if defined?(@course)
          @course
        else
          @course = provider.courses.find_by(code: course_code, recruitment_cycle_year:)
        end
      end

      def course_option
        return @course_option if defined?(@course_option)

        @course_option = course_options.find_by(site: { code: site_code }, study_mode:)
      end

      def course_options
        @course_options ||= course.course_options.joins(:site)
      end

      def site
        return @site if defined?(@site)

        @site = course_options.find_by(site: { code: site_code })
      end

      def option_study_mode
        return @option_study_mode if defined?(@option_study_mode)

        @option_study_mode = course_options.find_by(study_mode:)
      end
    end
  end
end

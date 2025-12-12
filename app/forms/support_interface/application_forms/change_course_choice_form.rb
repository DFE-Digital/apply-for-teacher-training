module SupportInterface
  module ApplicationForms
    class ChangeCourseChoiceForm
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks

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

      before_validation :strip_whitespace_from_attributes

      validates :provider_code, :course_code, :study_mode, :site_code, :audit_comment_ticket, :accept_guidance, presence: true
      validates :confirm_course_change, presence: true, if: :checkbox_rendered?

      validate :provider_exists
      validate :course_exists
      validate :study_mode_exists, if: :course_present?
      validate :site_exists

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
        return if provider.present?

        if provider_code.to_s.length.to_i != 3
          errors.add(:provider_code, :invalid_length)
        elsif !provider_code.to_s.match?(/[0-9A-Z]{3}/)
          errors.add(:provider_code, :invalid_format)
        else
          errors.add(:provider_code, :invalid_provider_code)
        end
      end

      def course_exists
        return if course.present?

        if course_code.to_s.length.to_i != 4
          errors.add(:course_code, :invalid_length)
        elsif !course_code.to_s.match?(/[0-9A-Z]{4}/)
          errors.add(:course_code, :invalid_format)
        elsif provider.present? && provider.courses.find_by(code: course_code).present?
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

        if site_code.to_s.length.to_i != 2
          errors.add(:site_code, :invalid_length)
        elsif !site_code.to_s.match?(/[A-Z]{2}/)
          errors.add(:site_code, :invalid_format)
        elsif option_study_mode.present?
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

      def strip_whitespace_from_attributes
        self.provider_code = provider_code.strip unless provider_code.nil?
        self.course_code = course_code.strip unless course_code.nil?
        self.site_code = site_code.strip unless site_code.nil?
        self.audit_comment_ticket = audit_comment_ticket.strip unless audit_comment_ticket.nil?
      end

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
        return if course_options.blank?
        return @course_option if defined?(@course_option)

        @course_option = course_options.find_by(site: { code: site_code }, study_mode:)
      end

      def course_options
        return if course.blank?

        @course_options ||= course.course_options.joins(:site)
      end

      def site
        return if course_options.blank?

        return @site if defined?(@site)

        @site = course_options.find_by(site: { code: site_code })
      end

      def option_study_mode
        return if course_options.blank?

        return @option_study_mode if defined?(@option_study_mode)

        @option_study_mode = course_options.find_by(study_mode:)
      end
    end
  end
end

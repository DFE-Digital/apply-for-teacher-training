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
          provider_id:,
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

      def provider_id
        provider = Provider.find_by(code: provider_code)

        raise CourseChoiceError, 'This is not a valid provider code' if provider.nil?

        provider.id
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
        @recruitment_cycle_year || RecruitmentCycle.current_year
      end
    end
  end
end

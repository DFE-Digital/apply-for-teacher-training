module SupportInterface
  class ApplicationChoiceComponent < ViewComponent::Base
    include ViewHelper
    include APIDocsHelper

    attr_reader :application_choice

    def initialize(application_choice)
      @application_choice = application_choice
    end

    def rows
      [
        status_row,
        offer_made_at_row,
        decline_by_default_at_row,
        course_candidate_applied_for_row,
        course_offered_by_provider_row,
        course_row,
        offer_conditions_row,
        rejected_at_or_by_default_at_row,
        rejection_reason_row,
        sent_to_provider_at_row,
        reject_by_default_at_row,
        vendor_api_row,
        register_api_row,
        interviews_row,
      ].compact
    end

    def title
      link_text = "<span class='govuk-visually-hidden'>Application choice ID</span> ##{application_choice.id}".html_safe
      href = support_interface_application_form_path(application_choice.application_form_id, anchor: anchor)

      "Application choice #{govuk_link_to(link_text, href)}".html_safe
    end

    def anchor
      "application-choice-#{application_choice.id}"
    end

  private

    def status_row
      {
        key: 'Status',
        value: render(SupportInterface::ApplicationStatusTagComponent.new(status: application_choice.status)),
      }.merge(status_action_link)
    end

    def offer_made_at_row
      return unless application_choice.offer?

      { key: 'Offer made at', value: application_choice.offered_at.to_s(:govuk_date_and_time) }
    end

    def decline_by_default_at_row
      return unless application_choice.offer?

      { key: 'Decline by default at', value: application_choice.decline_by_default_at.to_s(:govuk_date_and_time) } if application_choice.decline_by_default_at
    end

    def course_candidate_applied_for_row
      return unless application_choice.different_offer?

      { key: 'Course candidate applied for', value: render(CourseOptionDetailsComponent.new(course_option: application_choice.course_option)) }
    end

    def course_offered_by_provider_row
      return unless application_choice.different_offer?

      { key: 'Course offered by provider', value: render(CourseOptionDetailsComponent.new(course_option: application_choice.current_course_option)) }
    end

    def course_row
      return if application_choice.different_offer?

      { key: 'Course', value: render(CourseOptionDetailsComponent.new(course_option: application_choice.course_option)) }
    end

    def rejected_at_or_by_default_at_row
      return unless application_choice.rejected?

      if application_choice.rejected_by_default
        { key: 'Rejected by default at', value: application_choice.rejected_at.to_s(:govuk_date_and_time) }
      else
        { key: 'Rejected at', value: application_choice.rejected_at.to_s(:govuk_date_and_time) }
      end
    end

    def rejection_reason_row
      return unless rejection_reasons_text

      { key: 'Rejection reason', value: rejection_reasons_text }
    end

    def offer_conditions_row
      return unless application_choice.pending_conditions? || application_choice.offer?

      conditions = application_choice.offer&.[]('conditions')
      return if conditions.blank?

      {
        key: 'Conditions',
        value: render(SupportInterface::ConditionsComponent.new(conditions: conditions)),
        action: 'conditions',
        change_path: support_interface_edit_application_choice_conditions_path(application_choice_id: @application_choice.id),
      }
    end

    def sent_to_provider_at_row
      { key: 'Sent to provider at', value: application_choice.sent_to_provider_at.to_s(:govuk_date_and_time) } if application_choice.sent_to_provider_at
    end

    def reject_by_default_at_row
      { key: 'Reject by default at', value: application_choice.reject_by_default_at.to_s(:govuk_date_and_time) } if application_choice.reject_by_default_at && application_choice.decision_pending?
    end

    def vendor_api_row
      if visible_over_vendor_api?
        application_json = AllowedCrossNamespaceUsage::VendorAPISingleApplicationPresenter.new(application_choice).as_json
        {
          key: 'Vendor API',
          value: govuk_details(summary: 'See this application as it appears over the Vendor API') do
            json_code_sample(application_json)
          end,
        }
      else
        { key: 'Vendor API', value: 'This application hasn’t been sent to the provider yet, so it isn’t available over the Vendor API' }
      end
    end

    def register_api_row
      if visible_over_register_api?
        application_json = AllowedCrossNamespaceUsage::RegisterAPISingleApplicationPresenter.new(application_choice).as_json
        {
          key: 'Register API',
          value: govuk_details(summary: 'See this application as it appears over the Register API') do
            json_code_sample(application_json)
          end,
        }
      else
        { key: 'Register API', value: 'This candidate hasn’t been recruited, so the application isn’t available over the Register API' }
      end
    end

    def interviews_row
      return if application_choice.interviews.blank?

      interview_blocks = application_choice.interviews.order('created_at').map do |interview|
        render(SupportInterface::InterviewDetailsComponent.new(interview: interview))
      end

      { key: 'Interviews', value: interview_blocks }
    end

    def rejection_reasons_text
      @_rejection_reasons_text ||= begin
        if application_choice.structured_rejection_reasons.present?
          render(
            ReasonsForRejectionComponent.new(
              application_choice: application_choice,
              reasons_for_rejection: ReasonsForRejection.new(application_choice.structured_rejection_reasons),
              editable: false,
            ),
          )
        elsif application_choice.rejection_reason.present?
          application_choice.rejection_reason
        end
      end
    end

    def visible_over_vendor_api?
      ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.include?(application_choice.status.to_sym)
    end

    def visible_over_register_api?
      GetRecruitedApplicationChoices.call(
        recruitment_cycle_year: RecruitmentCycle.current_year,
      ).find_by(id: application_choice.id).present?
    end

    def status_action_link
      if FeatureFlag.active?(:support_user_reinstate_offer) && application_choice.declined? && !application_choice.declined_by_default
        {
          action: 'Reinstate offer',
          action_path: support_interface_application_form_application_choice_reinstate_offer_path(application_form_id: @application_choice.application_form.id, application_choice_id: @application_choice.id),
        }
      elsif application_choice.rejected? && !application_choice.rejected_by_default?
        {
          action: 'Revert rejection',
          action_path: support_interface_application_form_revert_rejection_path(application_form_id: @application_choice.application_form.id, application_choice_id: @application_choice.id),
        }
      else
        {}
      end
    end
  end
end

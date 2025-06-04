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
        application_number_row,
        status_row,
        withdrawal_reasons_row,
        offer_made_at_row,
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
        recommendations_row,
      ].compact
    end

  private

    def application_number_row
      {
        key: 'Application number',
        value: application_choice.id.to_s,
      }
    end

    def status_row
      {
        key: 'Status',
        value: render(SupportInterface::ApplicationStatusTagComponent.new(application_choice:)),
      }.merge(status_action_link)
    end

    def withdrawal_reasons_row
      if application_choice.withdrawn?
        {
          key: t('.reasons_for_withdrawal'),
          value: render(WithdrawalReasonsComponent.new(application_choice:)),
        }
      end
    end

    def offer_made_at_row
      return unless application_choice.offer?

      { key: 'Offer made at', value: application_choice.offered_at.to_fs(:govuk_date_and_time) }
    end

    def course_candidate_applied_for_row
      return unless application_choice.different_offer?

      {
        key: 'Course applied for',
        value: render(CourseOptionDetailsComponent.new(course_option: application_choice.course_option, application_choice:)),
      }
    end

    def course_offered_by_provider_row
      return unless application_choice.different_offer?

      {
        key: 'Course offered',
        value: render(CourseOptionDetailsComponent.new(course_option: application_choice.current_course_option, application_choice:)),
      }.merge(change_course_offered_link)
    end

    def course_row
      return if application_choice.different_offer?

      {
        key: 'Course',
        value: render(CourseOptionDetailsComponent.new(course_option: application_choice.course_option, application_choice:)),
      }.merge(change_course_choice_link).merge(change_course_offered_link)
    end

    def rejected_at_or_by_default_at_row
      return unless application_choice.rejected?

      if application_choice.rejected_by_default
        { key: 'Rejected by default at', value: application_choice.rejected_at.to_fs(:govuk_date_and_time) }
      else
        { key: 'Rejected at', value: application_choice.rejected_at.to_fs(:govuk_date_and_time) }
      end
    end

    def rejection_reason_row
      return unless rejection_reasons_text

      { key: 'Rejection reason', value: rejection_reasons_text }
    end

    def offer_conditions_row
      return if application_choice.pre_offer?

      conditions = application_choice.offer.text_conditions

      {
        key: 'Conditions',
        value: conditions.blank? ? 'No conditions added' : render(SupportInterface::ConditionsComponent.new(conditions:, application_choice:)),
        action: {
          href: support_interface_edit_application_choice_conditions_path(application_choice_id: @application_choice.id),
          visually_hidden_text: 'conditions',
        },
      }
    end

    def sent_to_provider_at_row
      { key: 'Sent to provider at', value: application_choice.sent_to_provider_at.to_fs(:govuk_date_and_time) } if application_choice.sent_to_provider_at
    end

    def reject_by_default_at_row
      { key: 'Reject by default at', value: application_choice.reject_by_default_at.to_fs(:govuk_date_and_time) } if application_choice.reject_by_default_at && application_choice.decision_pending?
    end

    def vendor_api_row
      if visible_over_vendor_api?
        application_json = AllowedCrossNamespaceUsage::VendorAPIApplicationPresenter.new(AllowedCrossNamespaceUsage::VendorAPIInfo.released_version, application_choice).as_json
        {
          key: 'Vendor API',
          value: govuk_details(summary_text: 'See this application as it appears over the Vendor API') do
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
          value: govuk_details(summary_text: 'See this application as it appears over the Register API') do
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
        render(SupportInterface::InterviewDetailsComponent.new(interview:))
      end

      { key: 'Interviews', value: interview_blocks }
    end

    def recommendations_row
      return unless application_choice.submitted?

      key = 'Recommended courses'
      recommended_courses_url = CandidateCoursesRecommender.recommended_courses_url(candidate: application_choice.candidate, locatable: application_choice.provider).presence
      value = govuk_link_to(recommended_courses_url, class: 'govuk-link govuk-link--no-visited-state', target: '_blank', rel: 'noopener') do
        "Recommended courses (based on #{application_choice.provider.name} location)"
      end

      { key:, value: }
    end

    def rejection_reasons_text
      return unless application_choice.rejection_reason.present? || application_choice.structured_rejection_reasons.present?

      @rejection_reasons_text ||= render(RejectionsComponent.new(application_choice:))
    end

    def visible_over_vendor_api?
      ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.include?(application_choice.status.to_sym)
    end

    def visible_over_register_api?
      GetRecruitedApplicationChoices.call(
        recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
      ).find_by(id: application_choice.id).present?
    end

    def change_course_choice_link
      return {} unless @application_choice.application_form.editable? && ChangeApplicationChoiceCourseOption::VALID_STATES.include?(application_choice.status.to_sym)

      {
        action: {
          href: support_interface_application_form_change_course_choice_path(application_form_id: @application_choice.application_form.id, application_choice_id: @application_choice.id),
          text: 'Change course choice',
        },
      }
    end

    def change_course_offered_link
      return {} unless @application_choice.pending_conditions? || @application_choice.unconditional_offer_pending_recruitment?

      {
        action: {
          href: support_interface_application_form_application_choice_change_offered_course_search_path(
            application_form_id: application_choice.application_form.id,
            application_choice_id: application_choice.id,
          ),
          text: 'Change offered course',
        },
      }
    end

    def status_action_link
      return {} unless @application_choice.application_form.editable?

      if application_choice.declined? && !application_choice.declined_by_default
        {
          action: {
            href: support_interface_application_form_application_choice_reinstate_offer_path(application_form_id: @application_choice.application_form.id, application_choice_id: @application_choice.id),
            text: 'Reinstate offer',
          },
        }
      elsif application_choice.withdrawn? && !any_successful_application_choices?(application_choice)
        {
          action: {
            href: support_interface_application_form_application_choice_revert_withdrawal_path(application_form_id: @application_choice.application_form.id, application_choice_id: @application_choice.id),
            text: 'Revert withdrawal',
          },
        }
      elsif application_choice.rejected? && !application_choice.rejected_by_default?
        {
          action: {
            href: support_interface_application_form_revert_rejection_path(application_form_id: @application_choice.application_form.id, application_choice_id: @application_choice.id),
            text: 'Revert rejection',
          },
        }
      elsif application_choice.recruited? || application_choice.conditions_not_met? || application_choice.offer_deferred?
        {
          action: {
            href: support_interface_application_form_application_choice_revert_to_pending_conditions_path(application_form_id: @application_choice.application_form.id, application_choice_id: @application_choice.id),
            text: 'Revert to pending conditions',
          },
        }
      else
        {}
      end
    end

    def any_successful_application_choices?(application_choice)
      choice_statuses = application_choice.application_form.application_choices.map(&:status)

      choice_statuses.any? { |choice_status| ApplicationStateChange::ACCEPTED_STATES.include? choice_status.to_sym }
    end
  end
end

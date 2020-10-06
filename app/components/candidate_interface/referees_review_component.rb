module CandidateInterface
  class RefereesReviewComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false, submitting_application: false)
      @application_form = application_form
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
      @submitting_application = submitting_application
    end

    def referee_rows(referee)
      [
        name_row(referee),
        email_row(referee),
        reference_type_row(referee),
        relationship_row(referee),
        feedback_status_row(referee),
      ].compact
    end

    def minimum_references
      ApplicationForm::MINIMUM_COMPLETE_REFERENCES
    end

    def show_missing_banner?
      !@application_form.references_completed && @editable && @submitting_application
    end

  private

    attr_reader :application_form

    def name_row(referee)
      {
        key: 'Name',
        value: referee.name,
        action: "name for #{referee.name}",
        change_path: candidate_interface_edit_referee_path(referee.id),
      }
    end

    def email_row(referee)
      {
        key: 'Email address',
        value: referee.email_address,
        action: "email address for #{referee.name}",
        change_path: candidate_interface_edit_referee_path(referee.id),
      }
    end

    def relationship_row(referee)
      {
        key: 'Relationship',
        value: referee.relationship,
        action: "relationship for #{referee.name}",
        change_path: candidate_interface_edit_referee_path(referee.id),
      }
    end

    def reference_type_row(referee)
      {
        key: 'Reference type',
        value: referee.referee_type ? referee.referee_type.capitalize.dasherize : '',
        action: "reference type for #{referee.name}",
        change_path: candidate_interface_referees_type_path(referee.id),
      }
    end

    def feedback_status_row(referee)
      value = feedback_status_label(referee) + feedback_status_content(referee)

      {
        key: 'Status',
        value: value,
      }
    end

    def feedback_status_label(reference)
      render(
        TagComponent.new(
          text: feedback_status_text(reference),
          type: feedback_status_colour(reference),
        ),
      )
    end

    def feedback_status_text(reference)
      return t('candidate_reference_status.feedback_overdue') if reference.feedback_overdue? && !reference.cancelled_at_end_of_cycle?

      t("candidate_reference_status.#{reference.feedback_status}")
    end

    def feedback_status_content(referee)
      if referee.not_requested_yet? && !referee.application_form.submitted?
        tag.p(t('application_form.referees.info.not_requested_yet'), class: 'govuk-body govuk-!-margin-top-2')
      elsif referee.feedback_refused?
        tag.p(t('application_form.referees.info.declined'), class: 'govuk-body govuk-!-margin-top-2')
      elsif referee.cancelled_at_end_of_cycle?
        tag.p(t('application_form.referees.info.cancelled_at_end_of_cycle'), class: 'govuk-body govuk-!-margin-top-2')
      elsif referee.feedback_overdue?
        tag.p(t('application_form.referees.info.feedback_overdue'), class: 'govuk-body govuk-!-margin-top-2')
      elsif referee.feedback_requested? && referee.requested_at > Time.zone.now - 5.days
        tag.p(t('application_form.referees.info.awaiting_reference_sent_less_than_5_days_ago'), class: 'govuk-body govuk-!-margin-top-2')
      elsif referee.feedback_requested?
        tag.p(t('application_form.referees.info.awaiting_reference_sent_more_than_5_days_ago'), class: 'govuk-body govuk-!-margin-top-2')
      elsif referee.cancelled?
        tag.p(t('application_form.referees.info.cancelled'), class: 'govuk-body govuk-!-margin-top-2')
      end
    end

    def feedback_status_colour(reference)
      case reference.feedback_status
      when 'not_requested_yet'
        :grey
      when 'feedback_requested'
        reference.feedback_overdue? ? :yellow : :purple
      when 'feedback_provided'
        :green
      when 'feedback_overdue'
        :yellow
      when 'cancelled', 'cancelled_at_end_of_cycle'
        :orange
      when 'feedback_refused', 'email_bounced'
        :red
      end
    end
  end
end

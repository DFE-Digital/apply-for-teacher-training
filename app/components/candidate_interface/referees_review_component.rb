module CandidateInterface
  class RefereesReviewComponent < ActionView::Component::Base
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
      @application_form = application_form
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
    end

    def referee_rows(referee)
      [
        name_row(referee),
        email_row(referee),
        relationship_row(referee),
        feedback_status_row(referee),
      ]
        .compact
    end

    def minimum_references
      ApplicationForm::MINIMUM_COMPLETE_REFERENCES
    end

    def show_missing_banner?
      @show_incomplete && @application_form.application_references.count < minimum_references && @editable
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

    def feedback_status_row(referee)
      {
        key: 'Status',
        value: feedback_status_label(referee.feedback_status),
      }
    end

    def feedback_status_label(status)
      I18n.t("candidate_reference_status.#{status}")
    end
  end
end

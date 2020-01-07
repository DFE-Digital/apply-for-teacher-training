module CandidateInterface
  class RefereesReviewComponent < ActionView::Component::Base
    include AriaDescribedbyHelper

    SECTION = 'referees'.freeze

    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
      @application_form = application_form
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
    end

    def referee_rows(work)
      [
        name_row(work),
        email_row(work),
        relationship_row(work),
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
        id: generate_id(section: SECTION, entry_id: referee.id, attribute: 'name'),
        key: 'Name',
        value: referee.name,
        action: 'name',
        change_path: candidate_interface_edit_referee_path(referee.id),
        aria_describedby: aria_describedby(referee.id),
      }
    end

    def email_row(referee)
      {
        key: 'Email address',
        value: referee.email_address,
        action: 'email address',
        change_path: candidate_interface_edit_referee_path(referee.id),
        aria_describedby: aria_describedby(referee.id),
      }
    end

    def relationship_row(referee)
      {
        key: 'Relationship',
        value: referee.relationship,
        action: 'relationship',
        change_path: candidate_interface_edit_referee_path(referee.id),
        aria_describedby: aria_describedby(referee.id),
      }
    end

    def aria_describedby(referee_id)
      generate_aria_describedby(
        section: SECTION,
        entry_id: referee_id,
        attributes: %w[name],
      )
    end
  end
end

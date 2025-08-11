module CandidateInterface
  class AdviserInterruptionForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :application_form
    attribute :proceed_to_request_adviser

    validates :proceed_to_request_adviser, presence: true

    def save
      return false if invalid?

      if proceed_to_request_adviser?
        application_form.update(adviser_interruption_response: true)
      else
        application_form.update(adviser_interruption_response: false)
      end
    end

    def proceed_to_request_adviser?
      proceed_to_request_adviser == 'yes'
    end

    def prefilled_teaching_subject?
      proceed_to_request_adviser? && degree_matches_with_adviser_teaching_subject?
    end

    def prefill_preferred_teaching_subject_id
      return unless degree_matches_with_adviser_teaching_subject?

      Adviser::TeachingSubject.find_by(title: recent_degree_subject).external_identifier
    end

    def recent_degree_subject
      application_form.application_qualifications.degrees.order(:award_year).last.subject.titleize
    end

  private

    def degree_matches_with_adviser_teaching_subject?
      return false unless application_form.degrees?

      Adviser::TeachingSubject.find_by(title: recent_degree_subject)
    end
  end
end

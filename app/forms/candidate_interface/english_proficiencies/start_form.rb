module CandidateInterface
  module EnglishProficiencies
    class StartForm
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks
      include Rails.application.routes.url_helpers

      attr_accessor :qualification_statuses, :application_form, :return_to

      before_validation :normalise_qualification_statuses

      validates :qualification_statuses, presence: true, inclusion: { in: EnglishProficiency.qualification_statuses.values }

      def save
        return false unless valid?

        raise_error_unless_application_form

        update_english_proficiencies.call
      end

      def next_path
        new_english_proficiency = update_english_proficiencies.new_english_proficiency

        if new_english_proficiency.has_qualification
          candidate_interface_english_proficiencies_type_path(new_english_proficiency)
        elsif new_english_proficiency.no_qualification || new_english_proficiency.degree_taught_in_english
          candidate_interface_english_proficiencies_no_qualification_details_path(new_english_proficiency)
        else
          candidate_interface_english_proficiencies_review_path
        end
      end

      def normalise_qualification_statuses
        return [] if qualification_statuses.blank?

        self.qualification_statuses = qualification_statuses.compact_blank
      end

      def fill(application_form)
        self.application_form = application_form
        self.qualification_statuses = (
          application_form.english_proficiency || application_form.english_proficiencies.last
        )&.qualification_statuses
        self
      end

    private

      def raise_error_unless_application_form
        if application_form.blank?
          raise MissingApplicationFormError
        end
      end

      def update_english_proficiencies
        @update_english_proficiencies ||= UpdateEnglishProficiencies.new(
          application_form:,
          qualification_statuses: qualification_statuses,
          english_proficiency: application_form.english_proficiency,
          persist: true,
        )
      end
    end
  end
end

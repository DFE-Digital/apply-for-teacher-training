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

        UpdateEnglishProficiencies.new(
          application_form,
          qualification_statuses: qualification_statuses,
          persist: true,
        ).call
      end

      def next_path
        if qualification_statuses.include?('has_qualification')
          candidate_interface_english_proficiencies_type_path(return_to_params)
        elsif qualification_statuses.include?('no_qualification') || qualification_statuses.include?('degree_taught_in_english')
          english_proficiency = application_form
            .english_proficiencies
            .where(qualification_status: %w[no_qualification degree_taught_in_english]).last
          candidate_interface_english_proficiencies_no_qualification_details_path(english_proficiency)
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
        self.qualification_statuses = application_form.english_proficiencies.pluck(:qualification_status).compact_blank
        self
      end

    private

      def raise_error_unless_application_form
        if application_form.blank?
          raise MissingApplicationFormError
        end
      end

      def return_to_params
        return_to == 'application-review' ? { 'return-to' => 'application-review' } : {}
      end
    end
  end
end

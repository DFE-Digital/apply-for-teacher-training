module CandidateInterface
  module EnglishProficiencies
    class NoQualificationDetailsForm
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      attr_accessor :declare_no_qualification_details, :no_qualification_details, :english_proficiency, :application_form, :return_to

      validates :declare_no_qualification_details, presence: true
      validates :no_qualification_details, presence: true, if: -> { qualification_details_declared? }

      def save
        return false unless valid?

        UpdateEnglishProficiencies.new(
          application_form,
          qualification_statuses: persisting_qualification_statuses,
          no_qualification_details: qualification_details_declared? ? no_qualification_details : nil ,
          persist: false,
        ).call
      end

      def fill(english_proficiency)
        self.declare_no_qualification_details = english_proficiency.no_qualification_details.present? ? 1 : 0
        self.no_qualification_details = english_proficiency.no_qualification_details
        self
      end

      def next_path
        candidate_interface_english_proficiencies_review_path
      end

      def qualification_details_declared?
        return false if declare_no_qualification_details.nil?

        declare_no_qualification_details.to_i.positive?
      end

    private

      def persisting_qualification_statuses
        @persisting_qualification_statuses ||= application_form.english_proficiencies.pluck(:qualification_status)
      end
    end
  end
end

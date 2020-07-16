module CandidateInterface
  module EnglishForeignLanguage
    class StartForm
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      attr_accessor :has_efl_qualification, :no_qualification_details, :application_form

      validates :has_efl_qualification, presence: true
      validates :no_qualification_details, word_count: { maximum: 200 }

      def save
        return false unless valid?

        case has_efl_qualification
        when 'has_qualification'
          true
        when 'qualification_not_needed'
          ActiveRecord::Base.transaction do
            application_form.english_proficiency&.destroy!
            application_form.build_english_proficiency(qualification_status: has_efl_qualification)
            application_form.english_proficiency.save!
          end
        when 'no_qualification'
          ActiveRecord::Base.transaction do
            application_form.english_proficiency&.destroy!
            application_form.build_english_proficiency(
              qualification_status: has_efl_qualification,
              no_qualification_details: no_qualification_details,
            )
            application_form.english_proficiency.save!
          end
        end
      end

      def next_path
        if has_efl_qualification == 'has_qualification'
          candidate_interface_english_foreign_language_type_path
        else
          candidate_interface_english_foreign_language_review_path
        end
      end
    end
  end
end

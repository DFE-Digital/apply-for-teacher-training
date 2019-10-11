module CandidateInterface
  class PersonalDetailsForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name,
                  :day, :month, :year,
                  :first_nationality, :second_nationality,
                  :english_main_language,
                  :english_language_details, :other_language_details

    def name
      "#{first_name} #{last_name}"
    end
  end
end

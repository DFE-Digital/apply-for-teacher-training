module CandidateInterface
  class PersonalDetailsForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name,
                  :day, :month, :year,
                  :first_nationality, :second_nationality,
                  :english_main_language,
                  :english_language_details, :other_language_details

    validates :first_name, :last_name, :english_main_language,
              :first_nationality,
              presence: true

    validates :first_name, :last_name,
              length: { maximum: 100 }

    # TODO: DoB valid date validation
    # TODO: Nationality matches existing nationalities array
    # TODO: Word count validation for english_language_details, other_language_details
    # TODO: Better validation content

    def name
      "#{first_name} #{last_name}"
    end
  end
end

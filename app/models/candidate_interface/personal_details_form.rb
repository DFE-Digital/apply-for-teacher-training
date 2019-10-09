module CandidateInterface
  class PersonalDetailsForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name, :day, :month, :year, :nationalities,
                  :english_main_language

    def name
      "#{first_name} #{last_name}"
    end
  end
end

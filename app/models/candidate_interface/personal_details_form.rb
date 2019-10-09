module CandidateInterface
  class PersonalDetailsForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name, :day, :month, :year, :nationality,
                  :english_main_language

    def name
      "#{first_name} #{last_name}"
    end

    def english_main_language_options
      [
        OpenStruct.new(id: 'yes', name: 'Yes'),
        OpenStruct.new(id: 'no', name: 'No'),
      ]
    end
  end
end

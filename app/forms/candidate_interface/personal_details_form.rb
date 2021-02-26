module CandidateInterface
  class PersonalDetailsForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name, :day, :month, :year

    validates :first_name, :last_name, presence: true, length: { maximum: 60 }
    validates :date_of_birth, date: { date_of_birth: true, presence: true }

    def self.build_from_application(application_form)
      new(
        first_name: application_form.first_name,
        last_name: application_form.last_name,
        day: application_form.date_of_birth&.day,
        month: application_form.date_of_birth&.month,
        year: application_form.date_of_birth&.year,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        first_name: first_name,
        last_name: last_name,
        date_of_birth: date_of_birth,
      )
    end

    def name
      "#{first_name} #{last_name}"
    end

    def date_of_birth
      date_args = [year, month, day].map(&:to_i)

      begin
        Date.new(*date_args)
      rescue ArgumentError
        Struct.new(:day, :month, :year).new(day, month, year)
      end
    end
  end
end

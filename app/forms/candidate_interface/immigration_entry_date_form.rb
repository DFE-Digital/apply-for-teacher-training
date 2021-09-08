module CandidateInterface
  class ImmigrationEntryDateForm
    include ActiveModel::Model

    attr_accessor :day, :month, :year

    validates :day, presence: true
    validates :month, presence: true
    validates :year, presence: true

    def self.build_from_application(application_form)
      new(
        day: application_form.immigration_entry_date&.day,
        month: application_form.immigration_entry_date&.month,
        year: application_form.immigration_entry_date&.year,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        immigration_entry_date: immigration_entry_date,
      )
    end

    def immigration_entry_date
      date_args = [year, month, day].map(&:to_i)

      begin
        Date.new(*date_args)
      rescue ArgumentError
        Struct.new(:day, :month, :year).new(day, month, year)
      end
    end
  end
end

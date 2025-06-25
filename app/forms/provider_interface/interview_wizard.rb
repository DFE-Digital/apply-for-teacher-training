module ProviderInterface
  class InterviewWizard
    include Wizard
    include Wizard::PathHistory
    include ActiveModel::Attributes

    attr_accessor :time, :location, :additional_details, :provider_id, :application_choice, :provider_user,
                  :path_history, :wizard_path_history
    attr_writer :date

    attribute 'date(3i)', :string
    attribute 'date(2i)', :string
    attribute 'date(1i)', :string

    validates :provider_user, :application_choice, presence: true
    validates :date, date: { presence: true }
    validates :time, presence: true
    validate :time_is_valid, unless: -> { time.blank? }
    validate :date_in_future, if: %i[date]
    validate :date_and_time_in_future, if: %i[date_and_time],
                                       unless: ->(c) { %i[date time].any? { |d| c.errors.attribute_names.include?(d) } }
    validates :provider_id, presence: true, if: %i[application_choice provider_user multiple_application_providers?]
    validates :location, presence: true, word_count: { maximum: 2000 }
    validates :additional_details, word_count: { maximum: 2000 }

    def date
      day = send('date(3i)')
      month = send('date(2i)')
      year = send('date(1i)')

      begin
        @date = Date.new(year.to_i, month.to_i, day.to_i)
      rescue ArgumentError
        @date = Struct.new(:day, :month, :year).new(day, month, year)
      end
    end

    def date_and_time
      Time.zone.local(date.year, date.month, date.day, parsed_time.hour, parsed_time.min) if date.is_a?(Date) && parsed_time.is_a?(Time)
    end

    def provider
      if multiple_application_providers?
        application_providers.find { |provider| provider.id == provider_id.to_i }
      else
        application_providers.first
      end
    end

    def self.from_model(store, interview, step = 'input', action = nil)
      wizard = new(store, { current_step: step, action: })

      wizard.additional_details ||= interview.additional_details
      wizard.application_choice = interview.application_choice
      wizard.send('date(1i)=', interview.date_and_time.year) if wizard.send('date(1i)').blank?
      wizard.send('date(2i)=', interview.date_and_time.month) if wizard.send('date(2i)').blank?
      wizard.send('date(3i)=', interview.date_and_time.day) if wizard.send('date(3i)').blank?
      wizard.location ||= interview.location
      wizard.provider_id ||= interview.provider_id
      wizard.time ||= interview.date_and_time.strftime('%-l:%M%P')

      wizard
    end

    def multiple_application_providers?
      @_multiple_application_providers ||= application_providers.many?
    end

  private

    def date_and_time_in_future
      return true if date_and_time > Time.zone.now

      if date.past?
        errors.add(:date, :past) unless errors.added?(:date, :past)
      else
        errors.add(:time, :past) unless errors.added?(:time, :past)
      end
      false
    end

    def date_in_future
      errors.add(:date, :past) if date.is_a?(Date) && date.past?
    end

    def parsed_time
      Timeliness.parse(time)
    end

    def time_is_valid
      return if parsed_time.present?

      errors.add(:time, :invalid)
    end

    def application_providers
      @_application_providers ||= application_choice.associated_providers
    end

    def state_excluded_attributes
      %w[state_store errors validation_context _application_providers _multiple_application_providers context_for_validation]
    end
  end
end

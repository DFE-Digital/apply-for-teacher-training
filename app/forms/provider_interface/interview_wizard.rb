module ProviderInterface
  class InterviewWizard
    include ActiveModel::Model
    include ActiveModel::Attributes

    VALID_TIME_FORMAT = /^(1[0-2]|0?[1-9])([:\.\s]?[0-5][0-9])?([AaPp][Mm])$/.freeze

    attr_accessor :time, :location, :additional_details, :provider_id, :application_choice, :provider_user, :current_step
    attr_writer :date

    attribute 'date(3i)', :string
    attribute 'date(2i)', :string
    attribute 'date(1i)', :string

    validate :date_is_valid?
    validate :date_and_time_in_future, if: %i[date_is_valid? time_is_valid?]
    validate :time_is_valid?, if: ->(wizard) { wizard.time.present? }
    validate :date_after_rbd_date, if: %i[date_is_valid? date_and_time_in_future]
    validates :time, :date, :provider_user, :location, :application_choice, presence: true
    validates :provider_id, presence: true, if: %i[application_choice provider_user multiple_application_providers?]

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
    end

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

    def date_is_valid?
      return true if date.is_a?(Date)

      return false if errors.added?(:date)

      empty_keys = date.to_h.select { |_, v| v.blank? }.keys
      errors.add(:date, :blank) and return(false) if empty_keys == date.to_h.keys
      errors.add(:date, :missing_values, missing_details: empty_keys.to_sentence) and return(false) if empty_keys.any?

      errors.add(:date, :invalid)
      false
    end

    def date_and_time
      Time.zone.local(date.year, date.month, date.day, parsed_time.hour, parsed_time.min) if date.is_a?(Date)
    end

    def date_and_time_in_future
      return true if date_and_time > Time.zone.now

      if date.past?
        errors.add(:date, :past) unless errors.added?(:date, :past)
      else
        errors.add(:time, :past) unless errors.added?(:time, :past)
      end
      false
    end

    def date_after_rbd_date
      errors.add(:date, :after_rdb) if date > application_choice.reject_by_default_at
    end

    def parsed_time
      Time.zone.parse(time.gsub(/[ .]/, ':'))
    end

    def time_is_valid?
      return true if time.match(VALID_TIME_FORMAT)

      errors.add(:time, :invalid)
      false
    end

    def provider
      # BUG Different return types break view component
      #if multiple_application_providers?
      #  application_providers
      #else
        application_providers.first
      #end
    end

    def multiple_application_providers?
      @multiple_application_providers ||= application_providers.count > 1
    end

    def application_providers
      @application_providers ||= [application_choice.provider, application_choice.accredited_provider].compact.uniq
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def self.from_model(store, interview, step = 'input')
      new(
        store,
        current_step: step,
        additional_details: interview.additional_details,
        application_choice: interview.application_choice,
        'date(1i)': interview.date_and_time.year,
        'date(2i)': interview.date_and_time.month,
        'date(3i)': interview.date_and_time.day,
        location: interview.location,
        provider_id: interview.provider_id,
        time: interview.date_and_time.strftime('%l:%M%P'),
      )
    end

  private

    def last_saved_state
      saved_state = @state_store.read
      saved_state ? JSON.parse(saved_state) : {}
    end

    def state
      as_json(except: %w[state_store errors validation_context]).to_json
    end
  end
end

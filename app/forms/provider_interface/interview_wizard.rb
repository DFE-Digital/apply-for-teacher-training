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
    validate :date_in_future, if: :date_is_valid?
    validate :time_is_valid?, if: ->(wizard) { wizard.time.present? }
    validate :date_after_rbd_date, if: :date_is_valid?
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

    def date_in_future
      errors.add(:date, :past) if date < Time.zone.now
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
      if multiple_application_providers?
        application_providers
      else
        application_providers.first
      end
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

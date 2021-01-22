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
    validate :date_in_future, if: ->(form) { form.date.present? }
    validate :time_is_valid?
    validates :date, :provider_user, :location, :application_choice, presence: true

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

      empty_keys = date.to_h.select { |_, v| v.blank? }.keys
      return errors[:date] << 'Enter the interview date' if empty_keys == date.to_h.keys
      return errors[:date] << "The interview date must include a #{empty_keys.to_sentence}" if empty_keys.any?

      errors[:date] << 'The interview date must be a real date'
    end

    def date_and_time
      Time.zone.local(date.year, date.month, date.day, parsed_time.hour, parsed_time.min) if date.is_a?(Date)
    end

    def date_in_future
      errors[:date] << 'The interview date must be in the future' if date.is_a?(Date) && date < Time.zone.now
    end

    def parsed_time
      Time.zone.parse(time.gsub(/[ .]/, ':'))
    end

    def time_is_valid?
      if time =~ VALID_TIME_FORMAT
        true
      else
        errors[:time] << 'Enter a valid time'
        false
      end
    end

    def provider
      if user_can_make_decisions_for_multiple_providers?
        provider_user.providers.find(provider_id)
      else
        providers_that_user_has_make_decisions_for.first
      end
    end

    def user_can_make_decisions_for_multiple_providers?
      providers_that_user_has_make_decisions_for.count > 1
    end

    def providers_that_user_has_make_decisions_for
      @_providers_that_user_has_make_decisions_for ||= begin
        application_choice_providers = [@application_choice.provider, @application_choice.accredited_provider].compact
        # TODO: Need to check permissions here so that user deffo has the rights
        current_user_providers = provider_user
          .provider_permissions
          .includes([:provider])
          .make_decisions
          .map(&:provider)

        current_user_providers.select { |provider| application_choice_providers.include?(provider) }
      end
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

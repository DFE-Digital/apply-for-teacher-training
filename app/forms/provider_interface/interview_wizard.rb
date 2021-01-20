module ProviderInterface
  class InterviewWizard
    include ActiveModel::Model

    VALID_TIME_FORMAT = /^(1[0-2]|0?[1-9])([:\.\s]?[0-5][0-9])?([AaPp][Mm])$/.freeze

    attr_accessor :day, :month, :year, :time, :location, :additional_details, :provider_id, :application_choice, :provider_user
    attr_accessor :current_step

    validate :date_is_valid?
    validate :date_and_time_in_future, if: ->(form) { form.date_is_valid? && form.time_is_valid? }
    validate :time_is_valid?
    validates :provider_user, :location, :application_choice, presence: true

    def initialize(state_store, attrs = {})
      @state_store = state_store
      super(last_saved_state.deep_merge(attrs))
    end

    def date_and_time
      Time.zone.local(year, month, day, parsed_time.hour, parsed_time.min)
    end

    def date_and_time_in_future
      errors[:date] << 'Enter a date in the future' if date_and_time < Time.zone.now
    end

    def date_is_valid?
      date_args = [year, month, day].map(&:to_i)
      if Date.valid_date?(*date_args)
        true
      else
        errors[:date] << 'Enter a valid date' unless Date.valid_date?(*date_args)
        false
      end
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

      if saved_state
        JSON.parse(saved_state)
      else
        {}
      end
    end

    def state
      as_json(except: %w[state_store errors validation_context]).to_json
    end
  end
end

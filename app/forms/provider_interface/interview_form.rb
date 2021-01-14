module ProviderInterface
  class InterviewForm
    include ActiveModel::Model

    attr_accessor :day, :month, :year, :time, :location, :additional_details, :application_choice, :provider_id, :current_provider_user

    validates :application_choice, :current_provider_user, presence: true
    validate :date_is_valid?
    validate :date_and_time_in_future, if: ->(form) { form.date_is_valid? && form.time_is_valid? }
    validate :time_is_valid?
    validates :location, presence: true

    def date_and_time
      Time.zone.local(year, month, day, time)
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

    def time_is_valid?
      # TODO: Specs to check this is valid!
      if time =~ /^(1[0-2]|0?[1-9])([:\.\s]?[0-5][0-9])?([AaPp][Mm])$/
        true
      else
        errors[:time] << 'Enter a valid time'
        false
      end
    end

    def date_and_time_in_future
      # TODO: Specs to ensure this is working
      errors[:date] << 'Enter a date in the future' if date_and_time < Time.zone.now
    end

    def provider
      if user_can_make_decisions_for_multiple_providers?
        current_provider_user.providers.find(provider_id)
      else
        providers_that_user_has_make_decisions_for.first
      end
    end

    def save
      return false unless valid?

      CreateInterview.new(
        actor: current_provider_user,
        application_choice: application_choice,
        provider: provider,
        date_and_time: date_and_time,
        location: location,
        additional_details: additional_details,
      ).save!
    end

    def user_can_make_decisions_for_multiple_providers?
      providers_that_user_has_make_decisions_for.count > 1
    end

    def providers_that_user_has_make_decisions_for
      @_providers_that_user_has_make_decisions_for ||= begin
        application_choice_providers = [application_choice.provider, application_choice.accredited_provider].compact
        # TODO: Need to check permissions here so that user deffo has the rights
        current_user_providers = current_provider_user
          .provider_permissions
          .includes([:provider])
          .make_decisions
          .map(&:provider)

        current_user_providers.select { |provider| application_choice_providers.include?(provider) }
      end
    end
  end
end

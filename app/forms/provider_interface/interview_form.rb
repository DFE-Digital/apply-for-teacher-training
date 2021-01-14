module ProviderInterface
  class InterviewForm
    include ActiveModel::Model

    attr_accessor :day, :month, :year, :time, :location, :additional_details, :application_choice, :provider_id, :current_provider_user

    validates :application_choice, presence: true
    validate :date_is_valid
    validate :time_is_valid
    validate :date_and_time_in_future, if: -> form { form.date_is_valid && form.time_is_valid }
    validates :location, presence: true

    def date_and_time
      Time.zone.local(year, month, day, time)
    end

    def date_is_valid
      date_args = [year, month, day].map(&:to_i)
      errors.add(:date, :blank) unless Date.valid_date?(*date_args)
    end

    def time_is_valid
      # TODO: Validation to check this is valid!
      errors.add(:time, "Enter a valid time") unless (time =~ /^(1[0-2]|0?[1-9])([:\.\s]?[0-5][0-9])?([AaPp][Mm])$/)
    end

    def date_and_time_in_future
      errors[:time] << 'Enter a date and time in the future' if date_and_time < Time.zone.now
    end

    def provider
      if make_decisions_permission_orgs.count > 1
        @current_provider_user.providers.find(provider_id)
      else
        make_decisions_permission_orgs.first
      end
    end

    def save
      valid?
    end

    def make_decisions_permission_orgs
      @_make_decisions_permission_orgs ||= begin
        application_choice_providers = [application_choice.provider, application_choice.accredited_provider].compact
        current_user_providers = current_provider_user
          .provider_permissions.includes([:provider])
          .make_decisions
        .map(&:provider)

        current_user_providers.select { |provider| application_choice_providers.include?(provider)  }
      end
    end
  end
end
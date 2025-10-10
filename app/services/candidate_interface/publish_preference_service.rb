module CandidateInterface
  class PublishPreferenceService
    def initialize(preference:, application_form:)
      @preference = preference
      @application_form = application_form
    end

    def call
      ActiveRecord::Base.transaction do
        publish_preference
        clean_up_locations_if_anywhere
        archive_other_published_preferences
        destroy_duplicated_preferences
      end

      PreferencesEmail.call(preference: @preference) if @preference.reload.published?
    end

  private

    def publish_preference
      @preference.published!
    end

    def clean_up_locations_if_anywhere
      return unless @preference.training_locations_anywhere?

      @preference.update(dynamic_location_preferences: nil)
      @preference.location_preferences.destroy_all
    end

    def archive_other_published_preferences
      @application_form.published_preferences.where.not(id: @preference.id).update_all(status: 'archived')
    end

    def destroy_duplicated_preferences
      @application_form.duplicated_preferences.where.not(id: @preference.id).destroy_all
    end
  end
end

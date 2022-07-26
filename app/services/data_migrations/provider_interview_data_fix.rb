module DataMigrations
  class ProviderInterviewDataFix
    TIMESTAMP = 20220720155903
    MANUAL_RUN = true

    def change
      interviews.each do |interview|
        interview.update_columns(
          location: '',
          additional_details: additional_details_for(interview),
        )
      end
    end

    # rubocop:disable Rails/Output
    def dry_run
      interviews.each do |interview|
        puts '-' * 80
        puts "Application number #{interview.application_choice.id}"
        puts '-' * 80
        puts

        if interview.additional_details.present?
          puts
          puts 'Move location value below AMENDING/ADDING to the additional details column:'
          puts
          puts "'#{additional_details_for(interview)}'"
        else
          puts 'Moving location value below to additional details column:'
          puts
          puts "'#{interview.location}'"
        end

        puts
      end
    end
  # rubocop:enable Rails/Output

  private

    def provider
      Provider.find_by(name: 'The Manchester Metropolitan University')
    end

    def interviews
      Interview.includes(:application_choice).where(provider_id: provider.id).where("location LIKE 'An email%'")
    end

    def additional_details_for(interview)
      if interview.additional_details.blank?
        interview.location
      else
        "#{interview.additional_details}\n\n#{interview.location}"
      end
    end
  end
end

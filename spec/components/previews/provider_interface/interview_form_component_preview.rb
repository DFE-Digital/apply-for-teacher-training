module ProviderInterface
  class InterviewFormComponentPreview < ViewComponent::Preview
    class FormModel
      include ActiveModel::Model
      attr_accessor :time, :date, :location, :additional_details, :provider_id

      def model_name
        # Required to load the correct localized strings in the form
        ActiveModel::Name.new(ProviderInterface::InterviewWizard)
      end
    end

    def create_interview
      form_object = FormModel.new

      render InterviewFormComponent.new(
        application_choice: example_application_choice,
        form_model: form_object,
        form_url: '',
        form_heading: 'Set up an interview',
      )
    end

    def edit_interview
      form_object = FormModel.new(example_form_attributes)

      render InterviewFormComponent.new(
        application_choice: example_application_choice,
        form_model: form_object,
        form_url: '',
        form_heading: 'Change interview details',
      )
    end

  private

    def example_application_choice
      application_choice = FactoryBot.build_stubbed(:application_choice, reject_by_default_at: 1.week.from_now)

      if rand > 0.5
        def application_choice.associated_providers
          [FactoryBot.build_stubbed(:provider), FactoryBot.build_stubbed(:provider)]
        end
      end

      application_choice
    end

    def example_form_attributes
      {
        time: rand(1..5).hours.from_now.strftime('%-l:%M%P'),
        date: rand(1..5).days.from_now,
        location: Faker::Lorem.sentence,
        additional_details: Faker::Lorem.sentence,
      }
    end
  end
end

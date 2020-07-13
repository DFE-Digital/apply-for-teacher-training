require 'rails_helper'

RSpec.describe ProviderEmailsForApplicationChoices do
  include CourseOptionHelpers

  describe '#as_hash' do
    it 'groups affected applications by email address' do
      provider_user = create(:provider_user, :with_provider, email_address: 'bob@example.com')
      option = course_option_for_provider(provider: provider_user.providers.first)
      choice1 = create(:submitted_application_choice, course_option: option)
      choice2 = create(:submitted_application_choice, course_option: option)

      result = ProviderEmailsForApplicationChoices.new([choice1.id, choice2.id]).as_hash

      expect(result.keys).to eq ['bob@example.com']
      expect(result['bob@example.com'][:affected_applications].count).to eq 2
    end

    it 'includes email addresses of users from the course’s accredited bodies' do
      provider_user = create(:provider_user, :with_provider, email_address: 'provider-pamela@example.com')
      accredited_provider_user = create(:provider_user, :with_provider, email_address: 'ratifying-roger@example.com')
      option = course_option_for_accredited_provider(
        provider: provider_user.providers.first,
        accredited_provider: accredited_provider_user.providers.first,
      )
      choice = create(:submitted_application_choice, course_option: option)

      result = ProviderEmailsForApplicationChoices.new([choice.id]).as_hash

      expect(result.keys).to match_array(['provider-pamela@example.com', 'ratifying-roger@example.com'])
    end
  end

  describe '#as_csv' do
    it 'renders the correct csv structure' do
      provider_user = create(:provider_user, :with_provider, first_name: 'Pamela', last_name: 'Provider', email_address: 'pamela@example.com')
      application_form = create(:completed_application_form,
                                first_name: 'Ciara',
                                last_name: 'Candidate',
                                support_reference: 'ABC123')

      option = course_option_for_provider(provider: provider_user.providers.first)
      application_choice = create(:submitted_application_choice, application_form: application_form, course_option: option)

      result = ProviderEmailsForApplicationChoices.new([application_choice.id]).as_csv

      expect(result).to include "email address,name,affected applications\n"
      expect(result).to include 'pamela@example.com,Pamela Provider,* Ciara Candidate (ABC123) (Submitted)'
      expect(result).to include "https://www.apply-for-teacher-training.service.gov.uk/provider/applications/#{application_choice.id}\n"
    end
  end
end

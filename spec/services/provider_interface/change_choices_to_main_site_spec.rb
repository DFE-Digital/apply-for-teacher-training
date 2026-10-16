require 'rails_helper'

RSpec.describe ProviderInterface::ChangeChoicesToMainSite do
  describe '.call' do
    context 'with provider_ids' do
      it 'enques a job to change the course_option to main site' do
        provider = create(:provider)
        course = create(:course, :open, provider:)
        main_site = create(:site, code: '-', provider:)

        old_course_option = create(:course_option, course:)
        _new_course_option = create(:course_option, course:, site: main_site)
        choice = create(
          :application_choice,
          current_course_option: old_course_option,
          original_course_option: old_course_option,
          school_placement_auto_selected: true,
        )
        described_class.call(provider_ids: [provider.id])

        expect(Provider::ChangeChoicesToMainSiteWorker).to have_been_enqueued.with(
          [choice.id],
        )
      end
    end

    context 'without choices that need updating' do
      it 'does not enques a job to change the course_option to main site' do
        provider = create(:provider)
        course = create(:course, :open, provider:)
        main_site = create(:site, code: '-', provider:)

        old_course_option = create(:course_option, course:)
        _new_course_option = create(:course_option, course:, site: main_site)
        _choice = create(
          :application_choice,
          current_course_option: old_course_option,
        )
        described_class.call(provider_ids: [provider.id])
        expect(Provider::ChangeChoicesToMainSiteWorker).not_to have_been_enqueued
      end
    end

    context 'without provider having a main site' do
      it 'does not enques a job to change the course_option to main site' do
        provider = create(:provider)
        course = create(:course, :open, provider:)

        old_course_option = create(:course_option, course:)
        _choice = create(
          :application_choice,
          current_course_option: old_course_option,
          original_course_option: old_course_option,
        )
        described_class.call(provider_ids: [provider.id])
        expect(Provider::ChangeChoicesToMainSiteWorker).not_to have_been_enqueued
      end
    end

    context 'without provider ids' do
      it 'does not enques a job to change the course_option to main site' do
        provider = create(:provider)
        course = create(:course, :open, provider:)
        main_site = create(:site, code: '-', provider:)

        old_course_option = create(:course_option, course:)
        _new_course_option = create(:course_option, course:, site: main_site)
        _choice = create(
          :application_choice,
          current_course_option: old_course_option,
          original_course_option: old_course_option,
        )
        described_class.call(provider_ids: 'wrong')
        expect(Provider::ChangeChoicesToMainSiteWorker).not_to have_been_enqueued
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Provider::ChangeChoicesToMainSiteWorker do
  describe '#perform' do
    context 'when there is a main site for the course' do
      it 'sets the choices to the main site' do
        provider = create(:provider)
        course = create(:course, provider:)
        main_site = create(:site, provider:)

        old_course_option = create(:course_option, course:)
        new_course_option = create(:course_option, course:, site: main_site)
        choice = create(
          :application_choice,
          current_course_option: old_course_option,
          course_option: old_course_option,
          original_course_option: old_course_option,
        )

        expect {
          described_class.new.perform([choice.id], main_site.id)
        }.to change { choice.reload.current_course_option }.from(old_course_option).to(new_course_option)
        .and change { choice.course_option }.from(old_course_option).to(new_course_option)
        .and change { choice.original_course_option }.from(old_course_option).to(new_course_option)
      end
    end

    context 'when there is not main site for the course' do
      it 'does not set the choices to the main site' do
        provider = create(:provider)
        course = create(:course, provider:)
        main_site = create(:site, provider:)

        course_option = create(:course_option, course:)
        choice = create(
          :application_choice,
          current_course_option: course_option,
        )

        expect {
          described_class.new.perform([choice.id], main_site.id)
        }.to not_change(choice.reload, :current_course_option)
        .and not_change(choice, :course_option)
        .and not_change(choice, :original_course_option)
      end
    end

    context 'when there is main site but there is not the same study mode' do
      it 'does not set the choices to the main site' do
        provider = create(:provider)
        course = create(:course, provider:)
        main_site = create(:site, provider:)

        old_course_option = create(:course_option, :part_time, course:)
        _new_course_option = create(:course_option, :full_time, course:, site: main_site)
        choice = create(
          :application_choice,
          current_course_option: old_course_option,
        )

        expect {
          described_class.new.perform([choice.id], main_site.id)
        }.to not_change(choice.reload, :current_course_option)
        .and not_change(choice, :course_option)
        .and not_change(choice, :original_course_option)
      end
    end
  end
end

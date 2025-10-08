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
        )

        expect {
          described_class.new.perform([choice.id], main_site.id)
        }.to change { choice.reload.current_course_option }.from(old_course_option).to(new_course_option)
      end
    end

    context 'when there is not main site for the course' do
      it 'sets the choices to the main site' do
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
        }.not_to(change { choice.reload.current_course_option })
      end
    end
  end
end

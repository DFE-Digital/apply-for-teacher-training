require 'rails_helper'

RSpec.describe CoursePathHelper do
  let(:application_choice) { build_stubbed(:application_choice) }

  describe '#offer_path_for' do
    context 'when :select_option' do
      it 'returns the application choice path' do
        expect(helper.course_path_for(application_choice, 'select_option'))
          .to eq(provider_interface_application_choice_path(application_choice, {}))
      end

      context 'when application_choice is pending_conditions' do
        let(:application_choice) { build_stubbed(:application_choice, :pending_conditions) }

        it 'returns the application choice path' do
          expect(helper.course_path_for(application_choice, 'select_option'))
            .to eq(provider_interface_application_choice_offer_path(application_choice))
        end
      end
    end

    context 'when :referer' do
      it 'returns the application choice path' do
        expect(helper.course_path_for(application_choice, 'referer'))
          .to eq(provider_interface_application_choice_path(application_choice, {}))
      end
    end

    context 'when any other step' do
      it 'returns the step edit path' do
        expect(helper.course_path_for(application_choice, :other_step, foo: 'bar'))
          .to eq([:edit, :provider_interface, application_choice, :course, :other_step, foo: 'bar'])
      end
    end
  end
end

require 'rails_helper'

RSpec.describe SupportInterface::CourseOptionDetailsComponent do
  subject(:render_component) do
    render_inline(
      described_class.new(
        course_option: @course_option,
        application_choice: @application_choice,
      ),
    )
  end

  describe 'Course type' do
    it 'renders postgraduate course' do
      @application_choice = build_stubbed(:application_choice)
      @course_option = @application_choice.course_option

      expect(render_component.css('.govuk-summary-list__key').text).to include('Course type')
      expect(render_component.css('.govuk-summary-list__value').text).to include('Postgraduate')
    end

    it 'renders undergraduate course' do
      @application_choice = build_stubbed(:application_choice, course_option: build_stubbed(:course_option, :tda))
      @course_option = @application_choice.course_option

      expect(render_component.css('.govuk-summary-list__key').text).to include('Course type')
      expect(render_component.css('.govuk-summary-list__value').text).to include('Undergraduate')
    end
  end

  describe 'Location' do
    context 'when it is the applications original course option and the location is auto selected' do
      it 'renders auto selected Location' do
        @application_choice = build_stubbed(:application_choice,
                                            course_option: build_stubbed(:course_option),
                                            original_course_option: build_stubbed(:course_option))
        @course_option = @application_choice.original_course_option
        location = @course_option.site.name_and_code

        expect(render_component.css('.govuk-summary-list__key').text).to include('Location (selected by candidate)')
        expect(render_component.css('.govuk-summary-list__value').text).to include(location)
      end
    end

    context 'when it is the applications original course option and the location is not auto selected' do
      it 'renders not auto selected Location' do
        @application_choice = build_stubbed(:application_choice,
                                            course_option: build_stubbed(:course_option),
                                            original_course_option: build_stubbed(:course_option),
                                            school_placement_auto_selected: true)
        @course_option = @application_choice.original_course_option
        location = @course_option.site.name_and_code

        expect(render_component.css('.govuk-summary-list__key').text).to include('Location (not selected by candidate)')
        expect(render_component.css('.govuk-summary-list__value').text).to include(location)
      end
    end

    context 'when the course option is not the original course option' do
      it 'renders undergraduate course' do
        @application_choice = build_stubbed(:application_choice,
                                            course_option: build_stubbed(:course_option),
                                            original_course_option: build_stubbed(:course_option))
        @course_option = @application_choice.current_course_option
        location = @course_option.site.name_and_code

        expect(render_component.css('.govuk-summary-list__key').text).to include('Location')
        expect(render_component.css('.govuk-summary-list__key').text).not_to include('Location (')
        expect(render_component.css('.govuk-summary-list__value').text).to include(location)
      end
    end
  end
end

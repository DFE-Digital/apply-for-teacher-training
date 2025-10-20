require 'rails_helper'

RSpec.describe ProviderInterface::ChangeCourseOfferSummaryComponent do
  include Rails.application.routes.url_helpers

  let(:application_choice) do
    build_stubbed(:application_choice,
                  :offered,
                  offer: build(:offer, conditions:))
  end
  let(:conditions) { [build(:text_condition, description: 'condition 1')] }
  let(:course_option) { build_stubbed(:course_option) }
  let(:providers) { [] }
  let(:course) { build_stubbed(:course) }
  let(:courses) { [] }
  let(:course_options) { [] }
  let(:editable) { false }
  let(:render) do
    render_inline(described_class.new(application_choice:,
                                      course_option:,
                                      conditions:,
                                      available_providers: providers,
                                      available_courses: courses,
                                      available_course_options: course_options,
                                      course:,
                                      editable: false))
  end

  def row_text_selector(row_name, render)
    rows = if course.accredited_provider.nil?
             {
               provider: 0,
               course: 1,
               full_or_part_time: 2,
               location: 3,
               qualification: 4,
               funding_type: 5,
             }
           else
             {
               provider: 0,
               course: 1,
               full_or_part_time: 2,
               location: 3,
               accredited_provider: 4,
               qualification: 5,
               funding_type: 6,
             }
           end

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  def row_link_selector(row_number)
    render.css('.govuk-summary-list__row')[row_number].css('a')&.first&.attr('href')
  end

  it 'renders the new course option details' do
    expect(row_text_selector(:provider, render)).to include(course_option.provider.name)
    expect(row_text_selector(:course, render)).to include(course_option.course.name_and_code)
    expect(row_text_selector(:location, render)).to include(course_option.site.name_and_address)
    expect(row_text_selector(:full_or_part_time, render)).to include(course_option.study_mode.humanize)
    expect(row_text_selector(:qualification, render)).to include('QTS with PGCE')
    expect(row_text_selector(:funding_type, render)).to include(course_option.course.funding_type.humanize)
  end

  context 'when application_choice is pending_conditions' do
    let(:application_choice) do
      build_stubbed(:application_choice,
                    :pending_conditions,
                    offer: build(:offer, conditions:))
    end

    context 'when multiple provider options' do
      let(:providers) { build_stubbed_list(:provider, 2) }

      it 'renders a change link' do
        provider_change_link = edit_provider_interface_application_choice_course_providers_path(
          application_choice,
        )
        expect(row_link_selector(0)).to eq(provider_change_link)
      end
    end

    context 'when only one provider option' do
      let(:providers) { [build_stubbed(:provider)] }

      it 'renders no change link' do
        expect(row_link_selector(0)).to be_nil
      end
    end

    context 'when multiple courses' do
      let(:courses) { build_stubbed_list(:course, 2) }

      it 'renders a change link' do
        course_change_link = edit_provider_interface_application_choice_course_courses_path(
          application_choice,
        )
        expect(row_link_selector(1)).to eq(course_change_link)
      end
    end

    context 'when only one course' do
      let(:courses) { [build_stubbed(:course)] }

      it 'renders no change link' do
        expect(row_link_selector(1)).to be_nil
      end
    end

    context 'when multiple study modes' do
      let(:course) { build_stubbed(:course, study_mode: :full_time_or_part_time) }

      it 'renders a change link' do
        study_mode_change_link = edit_provider_interface_application_choice_course_study_modes_path(
          application_choice,
        )
        expect(row_link_selector(2)).to eq(study_mode_change_link)
      end
    end

    context 'when only one study mode' do
      let(:course) { build_stubbed(:course, study_mode: :full_time) }

      it 'renders no change link' do
        expect(row_link_selector(2)).to be_nil
      end
    end

    context 'when multiple course options' do
      let(:course_options) { build_stubbed_list(:course_option, 2) }

      it 'renders a change link' do
        course_options_change_link = edit_provider_interface_application_choice_course_locations_path(
          application_choice,
        )
        expect(row_link_selector(3)).to eq(course_options_change_link)
      end
    end

    context 'when only one course option' do
      let(:course_options) { [build_stubbed(:course_option)] }

      it 'renders no change link' do
        expect(row_link_selector(3)).to be_nil
      end
    end
  end

  context 'when the accredited provider is not the same as the training provider' do
    let(:course) { build_stubbed(:course, :with_accredited_provider) }
    let(:course_option) { build_stubbed(:course_option, course:) }

    it 'renders an extra row with the accredited provider details' do
      expect(row_text_selector(:accredited_provider, render)).to include(course.accredited_provider.name_and_code)
    end
  end
end

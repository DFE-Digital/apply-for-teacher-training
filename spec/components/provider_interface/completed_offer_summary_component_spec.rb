require 'rails_helper'

RSpec.describe ProviderInterface::CompletedOfferSummaryComponent do
  let(:application_choice) do
    build_stubbed(:application_choice,
                  :with_offer,
                  offer: build(:offer, conditions: conditions))
  end
  let(:conditions) do
    [build(:offer_condition, text: 'condition 1'),
     build(:offer_condition, text: 'condition 2')]
  end
  let(:course_option) { build_stubbed(:course_option, course: course) }
  let(:providers) { [] }
  let(:course) { build_stubbed(:course, accredited_provider: build(:provider)) }
  let(:courses) { [] }
  let(:course_options) { [] }
  let(:render) do
    render_inline(described_class.new(application_choice: application_choice,
                                      course_option: course_option,
                                      conditions: conditions,
                                      available_providers: providers,
                                      available_courses: courses,
                                      available_course_options: course_options,
                                      course: course))
  end

  def row_text_selector(row_name, render)
    rows = {
      provider: 0,
      course: 1,
      full_or_part_time: 2,
      location: 3,
      accredited_provider: 4,
    }

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  def row_link_selector(row_number)
    render.css('.govuk-summary-list__row')[row_number].css('a')&.first&.attr('href')
  end

  context 'when multiple provider options' do
    let(:providers) { build_stubbed_list(:provider, 2) }

    it 'renders a change link' do
      provider_change_link = Rails.application.routes.url_helpers.edit_provider_interface_application_choice_offer_providers_path(application_choice)
      expect(row_link_selector(0)).to eq(provider_change_link)
    end
  end

  context 'when only one provider option' do
    let(:providers) { [build_stubbed(:provider)] }

    it 'renders no change link' do
      expect(row_link_selector(0)).to eq(nil)
    end
  end

  context 'when multiple courses' do
    let(:courses) { build_stubbed_list(:course, 2) }

    it 'renders a change link' do
      course_change_link = Rails.application.routes.url_helpers.edit_provider_interface_application_choice_offer_courses_path(application_choice)
      expect(row_link_selector(1)).to eq(course_change_link)
    end
  end

  context 'when only one course' do
    let(:courses) { [build_stubbed(:course)] }

    it 'renders no change link' do
      expect(row_link_selector(1)).to eq(nil)
    end
  end

  context 'when multiple study modes' do
    let(:course) { build_stubbed(:course, study_mode: :full_time_or_part_time) }

    it 'renders a change link' do
      study_mode_change_link = Rails.application.routes.url_helpers.edit_provider_interface_application_choice_offer_study_modes_path(application_choice)
      expect(row_link_selector(2)).to eq(study_mode_change_link)
    end
  end

  context 'when only one study mode' do
    let(:course) { build_stubbed(:course, study_mode: :full_time) }

    it 'renders no change link' do
      expect(row_link_selector(2)).to eq(nil)
    end
  end

  context 'when multiple course options' do
    let(:course_options) { build_stubbed_list(:course_option, 2) }

    it 'renders a change link' do
      course_options_change_link = Rails.application.routes.url_helpers.edit_provider_interface_application_choice_offer_locations_path(application_choice)
      expect(row_link_selector(3)).to eq(course_options_change_link)
    end
  end

  context 'when only one course option' do
    let(:course_options) { [build_stubbed(:course_option)] }

    it 'renders no change link' do
      expect(row_link_selector(3)).to eq(nil)
    end
  end

  it 'renders the new course option details' do
    expect(row_text_selector(:provider, render)).to include(course_option.provider.name)
    expect(row_text_selector(:course, render)).to include(course_option.course.name_and_code)
    expect(row_text_selector(:location, render)).to include(course_option.site.name_and_address)
    expect(row_text_selector(:full_or_part_time, render)).to include(course_option.study_mode.humanize)
    expect(row_text_selector(:accredited_provider, render)).to include(course_option.course.accredited_provider.name_and_code)
  end

  it 'renders conditions' do
    expect(render.css('[data-qa="conditions"]').text).to include('condition 1')
    expect(render.css('[data-qa="conditions"]').text).to include('condition 2')
  end
end

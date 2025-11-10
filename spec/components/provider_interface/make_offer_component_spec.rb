require 'rails_helper'

RSpec.describe ProviderInterface::MakeOfferComponent do
  include Rails.application.routes.url_helpers

  let(:application_choice) do
    create(:application_choice,
           :offered,
           offer: build(:offer, conditions:, ske_conditions:),
           school_placement_auto_selected:)
  end
  let(:school_placement_auto_selected) { false }
  let(:conditions) { [build(:text_condition, description: 'condition 1')] }
  let(:ske_conditions) { [create(:ske_condition)] }
  let(:course_option) { build(:course_option, course:) }
  let(:providers) { [] }
  let(:course) { build(:course, funding_type: 'fee') }
  let(:courses) { [] }
  let(:course_options) { [] }
  let(:render) do
    render_inline(
      described_class.new(
        application_choice:,
        course_option:,
        conditions: application_choice.offer.conditions,
        ske_conditions: application_choice.offer.ske_conditions,
        available_providers: providers,
        available_courses: courses,
        available_course_options: course_options,
        course:,
      ),
    )
  end

  def row_text_selector(row_name, render)
    rows = if course.accredited_provider.nil?
             {
               candidate: 0,
               provider: 1,
               course: 2,
               full_or_part_time: 3,
               location: 4,
               qualification: 5,
               funding_type: 6,
               conditions: 7,
               ske_header: 8,
               ske_subject: 9,
               ske_length: 10,
               ske_reason: 11,
             }
           else
             {
               candidate: 0,
               provider: 1,
               course: 2,
               full_or_part_time: 3,
               accredited_provider: 4,
               location: 5,
               qualification: 6,
               funding_type: 7,
             }
           end

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  def row_link_selector(row_number)
    render.css('.govuk-summary-list__row')[row_number].css('a')&.first&.attr('href')
  end

  context 'when multiple provider options' do
    let(:providers) { build_stubbed_list(:provider, 2) }

    it 'renders a change link' do
      provider_change_link = Rails.application.routes.url_helpers.new_provider_interface_application_choice_offer_providers_path(application_choice)
      expect(row_link_selector(1)).to eq(provider_change_link)
    end
  end

  context 'when only one provider option' do
    let(:providers) { [build_stubbed(:provider)] }

    it 'renders no change link' do
      expect(row_link_selector(1)).to be_nil
    end
  end

  context 'when multiple courses' do
    let(:courses) { build_stubbed_list(:course, 2) }

    it 'renders a change link' do
      course_change_link = Rails.application.routes.url_helpers.new_provider_interface_application_choice_offer_courses_path(application_choice)
      expect(row_link_selector(2)).to eq(course_change_link)
    end
  end

  context 'when only one course' do
    let(:courses) { [build_stubbed(:course)] }

    it 'renders no change link' do
      expect(row_link_selector(2)).to be_nil
    end
  end

  context 'when multiple course options' do
    let(:course_options) { build_stubbed_list(:course_option, 2) }

    it 'renders a change link' do
      course_options_change_link = Rails.application.routes.url_helpers.new_provider_interface_application_choice_offer_locations_path(application_choice)
      expect(row_link_selector(4)).to eq(course_options_change_link)
    end
  end

  context 'when only one course option' do
    let(:course_options) { [build_stubbed(:course_option)] }

    it 'renders no change link' do
      expect(row_link_selector(4)).to be_nil
    end
  end

  context 'when multiple study modes' do
    let(:course) { build_stubbed(:course, study_mode: :full_time_or_part_time) }

    it 'renders a change link' do
      study_mode_change_link = Rails.application.routes.url_helpers.new_provider_interface_application_choice_offer_study_modes_path(application_choice)
      expect(row_link_selector(3)).to eq(study_mode_change_link)
    end
  end

  context 'when only one study mode' do
    let(:course) { build_stubbed(:course, study_mode: :full_time) }

    it 'renders no change link' do
      expect(row_link_selector(2)).to be_nil
    end
  end

  context 'when school placement is auto selected' do
    let(:course) { build_stubbed(:course, study_mode: :full_time) }
    let(:school_placement_auto_selected) { true }

    it 'renders no change link' do
      expect(render).to have_content('(not selected by candidate)')
    end
  end

  context 'when school placement is candidate selected' do
    let(:course) { build_stubbed(:course, study_mode: :full_time) }

    it 'renders no change link' do
      expect(render).to have_content('(selected by candidate)')
    end
  end

  context 'conditions' do
    it 'renders a change link' do
      expect(row_link_selector(7)).to eq(
        new_provider_interface_application_choice_offer_conditions_path(application_choice),
      )
    end
  end

  context 'ske_conditions' do
    it 'renders a subject change link' do
      expect(row_link_selector(9)).to eq(
        new_provider_interface_application_choice_offer_ske_requirements_path(
          application_choice,
        ),
      )
    end

    it 'renders a length change link' do
      expect(row_link_selector(10)).to eq(
        new_provider_interface_application_choice_offer_ske_length_path(
          application_choice,
        ),
      )
    end

    it 'renders a reason change link' do
      expect(row_link_selector(11)).to eq(
        new_provider_interface_application_choice_offer_ske_reason_path(
          application_choice,
        ),
      )
    end
  end

  it 'renders the new course option details' do
    expect(row_text_selector(:candidate, render)).to include(application_choice.application_form.full_name)
    expect(row_text_selector(:provider, render)).to include(course_option.provider.name)
    expect(row_text_selector(:course, render)).to include(course_option.course.name_and_code)
    expect(row_text_selector(:location, render)).to include(course_option.site.full_address("\n"))
    expect(row_text_selector(:full_or_part_time, render)).to include(course_option.study_mode.humanize)
    expect(row_text_selector(:qualification, render)).to include('QTS with PGCE')
    expect(row_text_selector(:funding_type, render)).to include(course_option.course.funding_type.humanize)
    expect(row_text_selector(:conditions, render)).to include(
      application_choice.offer.conditions.map(&:description).join(' '),
    )
    expect(row_text_selector(:ske_header, render)).to include(
      'Subject knowledge enhancement course',
    )
    expect(row_text_selector(:ske_subject, render)).to include(
      ske_conditions.first.subject,
    )
    expect(row_text_selector(:ske_length, render)).to include(
      ske_conditions.first.length,
    )
    expect(row_text_selector(:ske_reason, render)).to include(
      "Their degree subject was not #{ske_conditions.first.subject}",
    )
  end

  context 'when the accredited provider is not the same as the training provider' do
    let(:course) { build_stubbed(:course, :with_accredited_provider) }
    let(:course_option) { build_stubbed(:course_option, course:) }

    it 'renders an extra row with the accredited provider details' do
      expect(row_text_selector(:accredited_provider, render)).to include(course.accredited_provider.name_and_code)
    end
  end
end

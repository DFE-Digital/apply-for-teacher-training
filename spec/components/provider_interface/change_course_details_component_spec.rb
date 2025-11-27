require 'rails_helper'

RSpec.describe ProviderInterface::ChangeCourseDetailsComponent do
  let(:course_option) do
    build_stubbed(:course_option,
                  :full_time,
                  course:,
                  site:)
  end

  let(:course_option2) do
    build_stubbed(:course_option,
                  :full_time,
                  course: course2,
                  site:)
  end

  let(:site) do
    build_stubbed(:site,
                  name: 'First Road',
                  code: 'F34',
                  address_line1: 'Fountain Street',
                  address_line2: 'Morley',
                  address_line3: 'Leeds',
                  postcode: 'LS27 OPD',
                  provider:)
  end

  let(:provider) do
    create(:provider,
           name: 'Best Training',
           code: 'B54')
  end

  let(:accredited_provider) do
    instance_double(Provider,
                    name_and_code: 'Accredit Now (A78)')
  end

  let(:course) do
    build_stubbed(:course,
                  :with_both_study_modes,
                  name: 'Geography',
                  code: 'H234',
                  recruitment_cycle_year: 2020,
                  accredited_provider: nil,
                  qualifications: %w[qts pgce],
                  funding_type: 'fee',
                  provider:)
  end

  let(:course2) do
    build_stubbed(:course,
                  :part_time,
                  name: 'Geography',
                  code: 'H234',
                  recruitment_cycle_year: 2020,
                  accredited_provider: nil,
                  qualifications: %w[qts pgce],
                  funding_type: 'fee')
  end

  let(:application_choice) do
    instance_double(ApplicationChoice,
                    course_option:,
                    current_course_option: course_option,
                    original_course_option: course_option,
                    different_offer?: false,
                    provider:,
                    school_placement_auto_selected?: true,
                    course:,
                    site:)
  end

  let(:single_study_mode_application_choice) do
    instance_double(ApplicationChoice,
                    course_option: course_option2,
                    current_course_option: course_option2,
                    original_course_option: course_option2,
                    different_offer?: false,
                    provider:,
                    school_placement_auto_selected?: false,
                    course: course2,
                    site:)
  end

  let(:render) { render_inline(described_class.new(application_choice:, course_option:)) }

  def row_text_selector(row_name, render)
    rows = { provider: 0,
             course: 1,
             full_or_part_time: 2,
             location: 3,
             accredited_body: 4,
             qualification: 5,
             funding_type: 6 }

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  def row_link_selector(row_number)
    render.css('.govuk-summary-list__row')[row_number].css('a')&.first&.attr('href')
  end

  context 'when there are multiple available providers' do
    let(:render) { render_inline(described_class.new(application_choice:, course_option:, available_providers: [provider, accredited_provider])) }

    it 'renders a link to change' do
      render_text = row_text_selector(:provider, render)

      expect(render_text).to include('Training provider')
      expect(render_text).to include('Best Training')
      expect(render_text).to include('Change')
    end
  end

  context 'when there are not multiple available providers' do
    it 'does not renders the change link' do
      render_text = row_text_selector(:provider, render)

      expect(render_text).to include('Training provider')
      expect(render_text).to include('Best Training')
      expect(render_text).not_to include('Change')
    end
  end

  context 'when multiple courses' do
    let(:render) { render_inline(described_class.new(application_choice:, course_option:, available_courses: [course, course2])) }

    it 'renders a change link' do
      render_text = row_text_selector(:course, render)

      expect(render_text).to include('Course')
      expect(render_text).to include('Geography (H234)')
      expect(render_text).to include('Change')
    end
  end

  context 'when only one course' do
    it 'does not render a change link' do
      render_text = row_text_selector(:course, render)

      expect(render_text).to include('Course')
      expect(render_text).to include('Geography (H234)')
      expect(render_text).not_to include('Change')
    end
  end

  context 'when there are multiple study modes' do
    it 'renders the study mode' do
      render_text = row_text_selector(:full_or_part_time, render)

      expect(render_text).to include('Full time or part time')
      expect(render_text).to include('Full time')
      expect(render_text).to include('Change')
    end
  end

  context 'when there is only one study mode' do
    let(:render) { render_inline(described_class.new(application_choice: single_study_mode_application_choice, course_option: course_option2, available_providers: [provider, accredited_provider])) }

    it 'renders the study mode' do
      render_text = row_text_selector(:full_or_part_time, render)

      expect(render_text).to include('Full time or part time')
      expect(render_text).to include('Full time')
      expect(render_text).not_to include('Change')
    end
  end

  context 'when there is only one location' do
    let(:render) { render_inline(described_class.new(application_choice: single_study_mode_application_choice, course_option:, available_course_options: [course_option])) }

    it 'does not render the change location link' do
      render_text = row_text_selector(:location, render)

      expect(render_text).to include('Location')
      expect(render_text).to include('First Road (F34)')
      expect(render_text).to include("Fountain Street\nMorley\nLeeds")
      expect(render_text).to include('LS27 OPD')
      expect(render_text).not_to include('Change')
    end
  end

  context 'when there are multiple locations' do
    let(:render) { render_inline(described_class.new(application_choice: single_study_mode_application_choice, course_option:, available_course_options: [course_option, course_option2])) }

    it 'renders the change link' do
      render_text = row_text_selector(:location, render)

      expect(render_text).to include('Location')
      expect(render_text).to include('First Road (F34)')
      expect(render_text).to include("Fountain Street\nMorley\nLeeds")
      expect(render_text).to include('LS27 OPD')
      expect(render_text).to include('Change')
    end
  end

  context 'when the locations is selected by the candidate' do
    let(:application_choice) do
      instance_double(ApplicationChoice,
                      course_option:,
                      current_course_option: course_option,
                      original_course_option: course_option,
                      different_offer?: false,
                      provider:,
                      school_placement_auto_selected?: false,
                      course:,
                      site:)
    end

    it 'says selected by candidate' do
      render_text = row_text_selector(:location, render)

      expect(render_text).to include('Location')
      expect(render_text).to include('First Road (F34)')
      expect(render_text).to include("Fountain Street\nMorley\nLeeds")
      expect(render_text).to include('LS27 OPD')
    end
  end

  context 'when the course option is not selected by the candidate' do
    let(:application_choice) do
      instance_double(ApplicationChoice,
                      course_option:,
                      current_course_option: course_option,
                      original_course_option: course_option2,
                      different_offer?: true,
                      provider:,
                      school_placement_auto_selected?: false,
                      course:,
                      site:)
    end

    it 'does not say selected by candidate' do
      render_text = row_text_selector(:location, render)

      expect(render_text).to include('Location')
      expect(render_text).not_to include('Location (')
      expect(render_text).to include('First Road (F34)')
      expect(render_text).to include("Fountain Street\nMorley\nLeeds")
      expect(render_text).to include('LS27 OPD')
    end
  end
end

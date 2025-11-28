require 'rails_helper'

RSpec.describe ProviderInterface::CourseDetailsComponent do
  let(:course_option) do
    create(:course_option,
           :full_time,
           course:,
           site:)
  end

  let(:course_option2) do
    create(:course_option,
           :full_time,
           course: course_with_accredited_body,
           site: site_with_accredited_provider)
  end

  let(:site) do
    create(:site,
           name: 'First Road',
           code: 'F34',
           address_line1: 'Fountain Street',
           address_line2: 'Morley',
           address_line3: 'Leeds',
           postcode: 'LS27 OPD',
           provider:)
  end

  let(:site_with_accredited_provider) do
    create(:site,
           name: 'First Road',
           code: 'F34',
           address_line1: 'Fountain Street',
           address_line2: 'Morley',
           address_line3: 'Leeds',
           postcode: 'LS27 OPD',
           provider: accredited_provider)
  end

  let(:provider) do
    create(:provider,
           name: 'Best Training',
           code: 'B54')
  end

  let(:accredited_provider) do
    create(:provider,
           name: 'Accredit Now',
           code: 'A78')
  end

  let(:course) do
    create(:course,
           :with_both_study_modes,
           name: 'Geography',
           code: 'H234',
           recruitment_cycle_year: 2020,
           accredited_provider: nil,
           qualifications: %w[qts pgce],
           funding_type: 'fee',
           provider:)
  end

  let(:course_with_accredited_body) do
    create(:course,
           name: 'Geography',
           code: 'H234',
           recruitment_cycle_year: 2020,
           provider: accredited_provider,
           accredited_provider:,
           qualifications: ['qts'],
           funding_type: 'fee')
  end

  let(:application_choice) do
    instance_double(ApplicationChoice,
                    current_course_option: course_option,
                    original_course_option: course_option,
                    course_option:,
                    different_offer?: false,
                    provider:,
                    course:,
                    school_placement_auto_selected?: true,
                    site:)
  end

  let(:application_choice_with_accredited_body) do
    instance_double(ApplicationChoice,
                    current_course_option: course_option2,
                    original_course_option: course_option2,
                    course_option: course_option2,
                    provider: accredited_provider,
                    different_offer?: false,
                    course: course_with_accredited_body,
                    school_placement_auto_selected?: true,
                    site: site_with_accredited_provider)
  end

  let(:render) { render_inline(described_class.new(application_choice:, course_option:)) }

  def row_text_selector(row_name, render)
    rows = { provider: 0,
             course: 1,
             cycle: 2,
             full_or_part_time: 3,
             location: 4,
             accredited_body: 5,
             qualification: 6,
             funding_type: 7 }

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  it 'renders the provider name' do
    render_text = row_text_selector(:provider, render)

    expect(render_text).to include('Training provider')
    expect(render_text).to include('Best Training')
  end

  context 'when an accredited body is present' do
    it 'renders the accredited body name and code when it is present' do
      render = render_inline(described_class.new(application_choice: application_choice_with_accredited_body, course_option: course_option2))

      render_text = render.css('.govuk-summary-list__row')[4].text

      expect(render_text).to include('Accredited body')
      expect(render_text).to include('Accredit Now')
    end
  end

  context 'when an accredited body is not present' do
    it 'renders the provider name and code in place of the accredited body name and code' do
      render_text = render.css('.govuk-summary-list__row')[4].text

      expect(render_text).to include('Accredited body')
      expect(render_text).to include('Best Training')
    end
  end

  it 'renders the course name and code' do
    render_text = row_text_selector(:course, render)

    expect(render_text).to include('Course')
    expect(render_text).to include('Geography (H234)')
  end

  it 'renders the recruitment cycle year' do
    render_text = row_text_selector(:cycle, render)

    expect(render_text).to include('Cycle')
    expect(render_text).to include('2020')
  end

  context 'when candidate did not select the location' do
    let(:application_choice) do
      instance_double(ApplicationChoice,
                      current_course_option: course_option,
                      original_course_option: course_option,
                      different_offer?: false,
                      course_option:,
                      provider:,
                      course:,
                      school_placement_auto_selected?: true,
                      site:)
    end

    it 'does not renders the preferred location' do
      render_text = render

      expect(render_text).not_to include('Location (not selected by candidate)')
      expect(render_text).not_to include('First Road (F34)')
      expect(render_text).not_to include("Fountain Street\nMorley\nLeeds")
      expect(render_text).not_to include('LS27 OPD')
    end
  end

  context 'when school placement is selected by candidate' do
    let(:application_choice) do
      instance_double(ApplicationChoice,
                      current_course_option: course_option,
                      original_course_option: course_option,
                      different_offer?: false,
                      course_option:,
                      provider:,
                      course:,
                      school_placement_auto_selected?: false,
                      site:)
    end

    it 'renders the preferred location' do
      render_text = row_text_selector(:location, render)

      expect(render_text).to include('Location')
    end
  end

  context 'when school placement is selected by support or provider' do
    let(:application_choice) do
      instance_double(ApplicationChoice,
                      current_course_option: course_option,
                      original_course_option: course_option2,
                      course_option:,
                      different_offer?: true,
                      provider:,
                      course:,
                      school_placement_auto_selected?: false,
                      site:)
    end

    it 'renders the preferred location' do
      render_text = row_text_selector(:location, render)

      expect(render_text).not_to include('Location (')
      expect(render_text).to include('Location')
    end
  end

  it 'renders the study mode' do
    render_text = row_text_selector(:full_or_part_time, render)

    expect(render_text).to include('Full time or part time')
    expect(render_text).to include('Full time')
  end

  it 'renders the qualification' do
    render_text = render.css('.govuk-summary-list__row')[5].text

    expect(render_text).to include('Qualification')
    expect(render_text).to include('QTS with PGCE')
  end

  it 'renders financing funding type of a course' do
    render_text = render.css('.govuk-summary-list__row')[6].text

    expect(render_text).to include('Funding type')
    expect(render_text).to include('Fee paying')
  end
end

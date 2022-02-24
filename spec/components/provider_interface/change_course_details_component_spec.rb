require 'rails_helper'

RSpec.describe ProviderInterface::ChangeCourseDetailsComponent do
  let(:course_option) do
    instance_double(CourseOption,
                    study_mode: 'Full time',
                    course: course)
  end

  let(:site) do
    instance_double(Site,
                    name_and_code: 'First Road (F34)',
                    address_line1: 'Fountain Street',
                    address_line2: 'Morley',
                    address_line3: 'Leeds',
                    postcode: 'LS27 OPD')
  end

  let(:provider) do
    instance_double(Provider,
                    name_and_code: 'Best Training (B54)')
  end

  let(:accredited_provider) do
    instance_double(Provider,
                    name_and_code: 'Accredit Now (A78)')
  end

  let(:course) do
    instance_double(Course,
                    name_and_code: 'Geograpghy (H234)',
                    recruitment_cycle_year: 2020,
                    accredited_provider: nil,
                    qualifications: %w[qts pgce],
                    funding_type: 'fee')
  end

  let(:application_choice) do
    instance_double(ApplicationChoice,
                    course_option: course_option,
                    provider: provider,
                    course: course,
                    site: site)
  end

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

  context 'when there are multiple available providers' do
    let(:render) { render_inline(described_class.new(application_choice: application_choice, available_providers: [provider, accredited_provider])) }

    it 'renders a link to change' do
      render_text = row_text_selector(:provider, render)

      expect(render_text).to include('Training provider')
      expect(render_text).to include('Best Training (B54)')
      expect(render_text).to include('Change')
    end
  end

  context 'when there are not multiple available providers' do
    let(:render) { render_inline(described_class.new(application_choice: application_choice)) }

    it 'does not renders the change link' do
      render_text = row_text_selector(:provider, render)

      expect(render_text).to include('Training provider')
      expect(render_text).to include('Best Training (B54)')
      expect(render_text).not_to include('Change')
    end
  end
end

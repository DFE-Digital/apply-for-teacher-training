require 'rails_helper'

RSpec.describe SupportInterface::ProviderCoursesTableComponent do
  describe 'course data' do
    it 'renders the correct data for a course' do
      course = create(:course,
                      :open,
                      name: 'My course',
                      code: 'ABC',
                      level: 'secondary',
                      recruitment_cycle_year: 2020)

      course_option = create(:course_option, course:)
      provider = course_option.course.provider

      render_result = render_inline(described_class.new(provider:, courses: provider.courses))

      # Make a mapping colname -> colvalue
      fields = render_result.css('th').map(&:text).zip(
        render_result.css('td').map(&:text),
      ).to_h

      expect(fields['Course']).to eq('My course (ABC)')
      expect(fields['Cycle']).to eq('2020')
      expect(fields['Status'].strip).to eq('Open')
      expect(fields).not_to have_key('Accredited body')
    end

    it 'may include courses the provider accredits' do
      provider = create(:provider)
      other_course_provider = create(:provider, name: 'Other provider')

      create(:course_option, course: create(:course,
                                            provider: other_course_provider,
                                            accredited_provider: provider,
                                            name: 'Accredited course'))

      render_result = render_inline(described_class.new(provider:, courses: provider.accredited_courses))

      expect(render_result.text).to include('Accredited course')
      expect(render_result.text).to include('Other provider')
    end

    context 'when there are accredited providers' do
      let(:accredited_provider) { create(:provider, :no_users, name: 'Accredited University', code: 'AU1') }
      let(:provider) { create(:provider) }

      let!(:course_with_accredited_provider) do
        create(
          :course,
          :open,
          provider:,
          name: 'My course',
          code: 'ABC',
          level: 'secondary',
          recruitment_cycle_year: 2020,
          accredited_provider:,
        )
      end

      let!(:course_without_accredited_provider) do
        create(
          :course,
          :open,
          provider:,
          name: 'My self-ratified course',
          code: 'DEF',
          level: 'secondary',
          recruitment_cycle_year: 2020,
          accredited_provider: nil,
        )
      end

      it 'may include accredited providers' do
        render_result = render_inline(described_class.new(provider:, courses: provider.courses))

        with_accredited = render_result.at_css("[data-qa=\"course-#{course_with_accredited_provider.id}\"]").text
        expect(with_accredited).to include('No users on Apply')
        expect(with_accredited).to include('Accredited University')

        without_accredited = render_result.at_css("[data-qa=\"course-#{course_without_accredited_provider.id}\"]").text
        expect(without_accredited).not_to include('No users on Apply')
      end
    end

    describe 'status_row' do
      subject { render_inline(described_class.new(provider: course.provider, courses: [course])).css('.govuk-table__cell').text }

      context 'course is open' do
        let(:course) { create(:course, :open) }

        it { is_expected.to match(/Open/) }
      end

      context 'course is not exposed in find' do
        let(:course) { create(:course, :open, exposed_in_find: false) }

        it { is_expected.to match(/Hidden in Find/) }
      end

      context 'course is closed by provider' do
        let(:course) { create(:course, :open, application_status: 'closed') }

        it { is_expected.to match(/Closed by provider/) }
      end

      context 'course is not open yet' do
        let(:course) { create(:course, :open, applications_open_from: 1.day.from_now) }

        it { is_expected.to match(/Unpublished/) }
      end

      context 'course is next recruitment cycle' do
        let(:course) { create(:course, :open, recruitment_cycle_year: next_year) }

        it { is_expected.to match(/Unpublished/) }
      end
    end
  end
end

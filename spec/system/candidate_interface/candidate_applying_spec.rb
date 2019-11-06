require 'rails_helper'

# TODO: This test needs to be rewritten to use the new acceptance-test style
# specs - https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training/pull/246
RSpec.describe 'A candidate applying from Find' do
  let(:provider_code) { '1AB' }
  let(:course_code) { '2ABC' }
  let(:course_name) { 'Biology' }

  shared_examples 'displays basic course information' do
    it 'sees the apply page' do
      expect(page).to have_content t('applying.heading')
    end

    it 'sees their provider code' do
      expect(page).to have_content provider_code
    end

    it 'sees their course code' do
      expect(page).to have_content course_code
    end

    it 'can apply through UCAS' do
      expect(page).to have_content t('applying.apply_button')
    end
  end

  context 'when Find is available' do
    context 'when a valid request is made' do
      let(:find_api_request) { stub_provider_200_from_find(provider_code, course_code) }

      before do
        find_api_request
        visit candidate_interface_apply_path providerCode: provider_code, courseCode: course_code
      end

      include_examples 'displays basic course information'

      it 'sees additional course information' do
        expect(page).to have_content "#{course_name} (#{course_code})"
      end

      it 'requests data from find' do
        expect(find_api_request).to have_been_made
      end
    end

    context 'when an invalid request is made' do
      let(:find_api_request) { stub_404_from_find('BAD', 'CODE') }

      before do
        find_api_request
        visit candidate_interface_apply_path providerCode: 'BAD', courseCode: 'CODE'
      end

      it 'sees an error page' do
        expect(page).to have_content t('applying.heading_not_found')
      end

      it 'requests data from find' do
        expect(find_api_request).to have_been_made
      end
    end

    context 'when query parameters are missing' do
      before do
        visit candidate_interface_apply_path
      end

      it 'sees an error page' do
        expect(page).to have_content t('applying.heading_not_found')
      end
    end
  end

  shared_examples 'falls back to basic version' do
    before do
      find_api_request
      visit candidate_interface_apply_path providerCode: provider_code, courseCode: course_code
    end

    include_examples 'displays basic course information'

    it 'does not see additional course information' do
      expect(page).not_to have_content "#{course_name} (#{course_code})"
    end

    it 'requests data from find' do
      expect(find_api_request).to have_been_made
    end
  end

  context 'when Find is returning server errors' do
    let(:find_api_request) { stub_503_from_find(provider_code, course_code) }

    include_examples 'falls back to basic version'
  end

  context 'when Find is timing out' do
    let(:find_api_request) { stub_timeout_from_find(provider_code, course_code) }

    include_examples 'falls back to basic version'
  end

  def stub_api_find_course(provider_code, course_code)
    stub_request(:get, ENV.fetch('FIND_BASE_URL') +
      'recruitment_cycles/2020' \
      "/providers/#{provider_code}" \
      "/courses/#{course_code}")
  end

  def stub_provider_200_from_find(provider_code, course_code)
    stub_api_find_course(provider_code, course_code)
      .to_return(
        status: 200,
        headers: { 'Content-Type': 'application/vnd.api+json' },
        body: {
          'data' => {
            'id' => '1',
            'type' => 'courses',
            'attributes' => {
              'course_code' => course_code,
              'name' => course_name,
              'provider_code' => provider_code,
            },
          },
          'jsonapi' => { 'version' => '1.0' },
        }.to_json,
      )
  end

  def stub_404_from_find(provider_code, course_code)
    stub_api_find_course(provider_code, course_code)
      .to_return(status: 404)
  end

  def stub_503_from_find(provider_code, course_code)
    stub_api_find_course(provider_code, course_code)
      .to_return(status: 503)
  end

  def stub_timeout_from_find(provider_code, course_code)
    stub_api_find_course(provider_code, course_code)
      .to_timeout
  end
end

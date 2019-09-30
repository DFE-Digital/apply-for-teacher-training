require 'rails_helper'

describe 'A candidate applying from Find' do
  let(:provider_code) { '1AB' }
  let(:course_code) { '2ABC' }
  let(:course_name) { 'Biology' }

  shared_examples 'displays basic course information' do
    it 'sees the apply page' do
      expect(page).to have_content t('apply.heading')
    end

    it 'sees their provider code' do
      expect(page).to have_content provider_code
    end

    it 'sees their course code' do
      expect(page).to have_content course_code
    end

    it 'can apply through UCAS' do
      expect(page).to have_content t('apply.apply_button')
    end
  end

  context 'when Find is available' do
    before do
      stub_find_is_up
    end

    context 'when a valid request is made' do
      before do
        visit candidate_interface_apply_path providerCode: provider_code, courseCode: course_code
      end

      include_examples 'displays basic course information'

      it 'sees additional course information' do
        expect(page).to have_content "#{course_name} (#{course_code})"
      end
    end

    context 'when an invalid request is made' do
      before do
        visit candidate_interface_apply_path providerCode: 'BAD', courseCode: 'CODE'
      end

      it 'sees an error page' do
        expect(page).to have_content t('apply.heading_not_found')
      end
    end

    context "when query parameters are missing" do
      before do
        visit candidate_interface_apply_path
      end

      it 'sees an error page' do
        expect(page).to have_content t('applying.heading_not_found')
      end
    end
  end

  context 'when Find is unavailable' do
    before do
      stub_find_is_down
      visit candidate_interface_apply_path providerCode: provider_code, courseCode: course_code
    end

    include_examples 'displays basic course information'

    it 'does not see additional course information' do
      expect(page).not_to have_content "#{course_name} (#{course_code})"
    end
  end

  def stub_api_find_course(provider_code, course_code)
    stub_request(:get, 'https://bat-qa-mcbe-as.azurewebsites.net/api/v3' \
      '/recruitment_cycles/2020' \
      "/providers/#{provider_code}" \
      "/courses/#{course_code}")
  end

  def stub_find_is_up
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

    stub_api_find_course('BAD', 'CODE')
      .to_return(status: 404)
  end

  def stub_find_is_down
    stub_api_find_course(provider_code, course_code)
      .to_return(status: 503)
  end
end

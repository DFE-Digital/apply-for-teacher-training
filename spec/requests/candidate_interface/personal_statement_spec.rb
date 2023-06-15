require 'rails_helper'

RSpec.describe 'PUT candidate/application/equality-and-diversity' do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate) }
  let(:application_form) { create(:application_form, candidate: candidate) }

  before do
    sign_in candidate
  end

  describe 'GET /candidate/application/personal-statement' do
    it 'responds with 200' do
      get candidate_interface_new_becoming_a_teacher_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /candidate/application/personal-statement/edit' do
    context 'when becoming_a_teacher is blank' do
      let(:params) do
        {
          candidate_interface_becoming_a_teacher_form: {
            becoming_a_teacher: '',
          },
        }
      end

      it 'redirects to application form page' do
        patch candidate_interface_new_becoming_a_teacher_path, params: params

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(candidate_interface_application_form_path)
      end
    end

    context 'when becoming_a_teacher is invalid' do
      let(:params) do
        {
          candidate_interface_becoming_a_teacher_form: {
            becoming_a_teacher: 'Some ' * 1001,
          },
        }
      end

      it 'redirects to review page' do
        patch candidate_interface_edit_becoming_a_teacher_path, params: params

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
      end
    end

    context 'when becoming_a_teacher with content' do
      let(:params) do
        {
          candidate_interface_becoming_a_teacher_form: {
            becoming_a_teacher: 'Some content',
          },
        }
      end

      it 'redirects to review page' do
        patch candidate_interface_edit_becoming_a_teacher_path, params: params

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
      end
    end

    context 'when saving to db fails' do
      let(:params) do
        {
          candidate_interface_becoming_a_teacher_form: {
            becoming_a_teacher: 'content',
          },
        }
      end

      it 'renders the error message' do
        allow_any_instance_of(ApplicationForm).to receive(:update).and_return(false) # rubocop:disable RSpec/AnyInstance

        patch candidate_interface_edit_becoming_a_teacher_path, params: params

        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include('The record could not be saved. Please try again.')
      end
    end
  end

  describe 'PATCH /candidate/application/personal-statement' do
    context 'when becoming_a_teacher with content' do
      let(:params) do
        {
          candidate_interface_becoming_a_teacher_form: {
            becoming_a_teacher: 'Some content',
          },
        }
      end

      it 'redirects to review page' do
        patch candidate_interface_new_becoming_a_teacher_path, params: params

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
      end
    end

    context 'when becoming_a_teacher is blank' do
      let(:params) do
        {
          candidate_interface_becoming_a_teacher_form: {
            becoming_a_teacher: '',
          },
        }
      end

      it 'redirects to application form page' do
        patch candidate_interface_new_becoming_a_teacher_path, params: params

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(candidate_interface_application_form_path)
      end
    end

    context 'when becoming_a_teacher is invalid' do
      let(:params) do
        {
          candidate_interface_becoming_a_teacher_form: {
            becoming_a_teacher: Faker::Lorem.paragraph_by_chars(number: 1001),
          },
        }
      end

      it 'redirects to review page' do
        patch candidate_interface_new_becoming_a_teacher_path, params: params

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
      end
    end

    context 'when saving to db fails' do
      let(:params) do
        {
          candidate_interface_becoming_a_teacher_form: {
            becoming_a_teacher: 'content',
          },
        }
      end

      it 'renders the error message' do
        allow_any_instance_of(ApplicationForm).to receive(:update).and_return(false) # rubocop:disable RSpec/AnyInstance

        patch candidate_interface_edit_becoming_a_teacher_path, params: params

        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include('The record could not be saved. Please try again.')
      end
    end
  end
end

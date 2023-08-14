require 'rails_helper'

# TODO: create and complete action
RSpec.describe 'CandidateInterface::BecomingATeacherController' do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate) }
  let!(:application_form) { create(:application_form, candidate: candidate) }
  let(:params) do
    {
      candidate_interface_becoming_a_teacher_form: {
        becoming_a_teacher: becoming_a_teacher,
      },
    }
  end

  before do
    sign_in candidate
  end

  describe 'GET /candidate/application/personal-statement' do
    it 'responds with 200' do
      get candidate_interface_new_becoming_a_teacher_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /candidate/application/personal-statement/review' do
    it 'responds with 200' do
      get candidate_interface_becoming_a_teacher_show_path

      expect(response).to have_http_status(:ok)
    end

    context 'when the application form is submitted' do
      let(:application_form) { create(:application_form, :submitted, candidate: candidate) }

      it 'redirects to the dashboard' do
        get candidate_interface_becoming_a_teacher_show_path

        expect(response).to redirect_to(candidate_interface_application_complete_path)
      end
    end

    context 'when the application form is submitted in continuous applications', continuous_applications: true do
      let(:application_form) { create(:application_form, :submitted, :continuous_applications, candidate: candidate) }

      it 'responds with 200' do
        get candidate_interface_becoming_a_teacher_show_path

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH /candidate/application/personal-statement' do
    context 'when becoming_a_teacher with content' do
      let(:becoming_a_teacher) { 'Valid content' }

      it 'redirects to review page' do
        patch candidate_interface_new_becoming_a_teacher_path, params: params

        expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
      end

      context 'when the application form is submitted' do
        let(:application_form) { create(:application_form, :submitted, candidate: candidate) }

        it 'redirects to the complete page' do
          patch candidate_interface_new_becoming_a_teacher_path, params: params

          expect(response).to redirect_to(candidate_interface_application_complete_path)
        end
      end

      context 'when the application form is submitted in continuous applications', continuous_applications: true do
        let(:application_form) { create(:application_form, :submitted, :continuous_applications, candidate: candidate) }

        it 'redirects to the review page' do
          patch candidate_interface_new_becoming_a_teacher_path, params: params

          expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
        end
      end
    end

    context 'when becoming_a_teacher is blank' do
      let(:becoming_a_teacher) { '' }

      it 'redirects to application form page' do
        patch candidate_interface_new_becoming_a_teacher_path, params: params

        expect(response).to redirect_to(candidate_interface_application_form_path)
      end
    end

    context 'when becoming_a_teacher is invalid' do
      let(:becoming_a_teacher) { 'Some ' * 1001 }

      it 'redirects to review page' do
        patch candidate_interface_new_becoming_a_teacher_path, params: params

        expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
      end
    end
  end

  describe 'PATCH /candidate/application/personal-statement/edit' do
    context 'when becoming_a_teacher is blank' do
      let(:becoming_a_teacher) { '' }

      it 'redirects to application form page' do
        patch candidate_interface_new_becoming_a_teacher_path, params: params

        expect(response).to redirect_to(candidate_interface_application_form_path)
      end
    end

    context 'when becoming_a_teacher is invalid' do
      let(:becoming_a_teacher) { 'Some ' * 1001 }

      it 'redirects to review page' do
        patch candidate_interface_edit_becoming_a_teacher_path, params: params

        expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
      end
    end

    context 'when becoming_a_teacher with content' do
      let(:becoming_a_teacher) { 'Valid content' }

      it 'redirects to review page' do
        patch candidate_interface_edit_becoming_a_teacher_path, params: params

        expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
      end

      context 'when the application form is submitted' do
        let!(:application_form) { create(:application_form, :submitted, candidate: candidate) }

        it 'redirects to the complete page' do
          patch candidate_interface_edit_becoming_a_teacher_path, params: params

          expect(response).to redirect_to(candidate_interface_application_complete_path)
        end
      end

      context 'when the application form is submitted in continuous applications', continuous_applications: true do
        let!(:application_form) { create(:application_form, :submitted, :continuous_applications, candidate: candidate) }

        it 'redirects to the review page' do
          patch candidate_interface_edit_becoming_a_teacher_path, params: params

          expect(response).to redirect_to(candidate_interface_becoming_a_teacher_show_path)
        end
      end
    end
  end
end

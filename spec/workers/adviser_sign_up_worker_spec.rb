require 'rails_helper'

RSpec.describe AdviserSignUpWorker do
  include_context 'get into teaching api stubbed endpoints'

  before do
    TestSuiteTimeMachine.travel_permanently_to(date)

    allow(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to receive(:new) { api_double }
    allow(Adviser::CandidateMatchback).to receive(:new).and_return(candidate_matchback_double)
  end

  let(:date) { Date.new(Time.zone.today.year, 9, 6) }
  let(:application_form) { create(:application_form_eligible_for_adviser) }
  let(:degree) { application_form.application_qualifications.degrees.last }
  let(:candidate_matchback_double) { instance_double(Adviser::CandidateMatchback, teacher_training_adviser_sign_up: Adviser::TeacherTrainingAdviserSignUpDecorator.new({})) }
  let(:api_double) { instance_double(GetIntoTeachingApiClient::TeacherTrainingAdviserApi, sign_up_teacher_training_adviser_candidate: nil) }
  let(:constants) { Adviser::Constants }
  let(:adviser_teaching_subject) { create(:adviser_teaching_subject, external_identifier: preferred_teaching_subject.id) }
  let(:adviser_sign_up_request) { create(:adviser_sign_up_request, application_form: application_form, teaching_subject: adviser_teaching_subject) }

  subject(:perform) do
    described_class.new.perform(
      adviser_sign_up_request.id,
    )
  end

  describe '#perform' do
    context 'when the AdviserSignUpRequest has already been sent' do
      let(:adviser_sign_up_request) {
        create(:adviser_sign_up_request, :sent_to_adviser,
               application_form: application_form,
               teaching_subject: adviser_teaching_subject)
      }

      it 'does not resend the sign up to the API' do
        perform

        expect(api_double).not_to have_received(:sign_up_teacher_training_adviser_candidate)
      end
    end

    it 'sends a request to sign up for an adviser' do
      expect_sign_up do |attributes|
        expect(attributes.values).to all(be_present)
      end
    end

    it 'marks the AdviserSignUpRequest as sent' do
      expect {
        perform
      }.to change { adviser_sign_up_request.reload.sent_to_adviser? }.from(false).to(true)
    end

    it 'sends matchback attributes when the candidate already exists in the GiT API' do
      waiting_to_be_assigned = 222_750_001
      matchback_attributes = {
        candidate_id: SecureRandom.uuid,
        qualification_id: SecureRandom.uuid,
        adviser_status_id: waiting_to_be_assigned,
      }

      api_model = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(matchback_attributes)
      allow(candidate_matchback_double).to receive(:teacher_training_adviser_sign_up) { Adviser::TeacherTrainingAdviserSignUpDecorator.new(api_model) }

      expect_sign_up(matchback_attributes)
    end

    it 'sends graduated for degree_status_id if the degree has been completed' do
      degree.update(predicted_grade: false)
      expect_sign_up(degree_status_id: constants.fetch(:degree_status, :graduated))
    end

    it 'sends unknown for country_id when the country ISO code is not matched' do
      application_form.update(country: 'UNMATCHED')
      expect_sign_up(country_id: constants.fetch(:countries, :unknown))
    end

    context 'when the preferred_teaching_subject_id is primary' do
      let(:primary_subject_id) { constants.fetch(:teaching_subjects, :primary) }
      let(:preferred_teaching_subject) { GetIntoTeachingApiClient::TeachingSubject.new(id: primary_subject_id) }

      it 'sends primary for preferred_education_phase_id' do
        expect_sign_up(preferred_education_phase_id: constants.fetch(:education_phases, :primary))
      end
    end

    context "when it's after the current ITT year cutoff point" do
      let(:date) { Date.new(Time.zone.today.year, 9, 7) }

      it 'sends next year as the initial_teacher_training_year_id' do
        expect_sign_up(initial_teacher_training_year_id: next_year.id)
      end
    end

    context 'when the degree is international' do
      let(:application_form) { create(:completed_application_form, :with_international_degree) }

      it 'does not send the international degree type' do
        perform

        expect(api_double).not_to have_received(:sign_up_teacher_training_adviser_candidate)
      end
    end

    describe 'sending GCSE qualification details' do
      it "sends no for has_gcse_maths_and_english_id if they haven't got Maths or English GCSEs" do
        application_form.maths_gcse.destroy
        application_form.english_gcse.destroy

        expect_sign_up(has_gcse_maths_and_english_id: constants.fetch(:gcse, false))
      end

      it 'sends no for has_gcse_maths_and_english_id if they have passed Maths but not English GCSEs' do
        application_form.english_gcse.update(grade: 'Z')

        expect_sign_up(has_gcse_maths_and_english_id: constants.fetch(:gcse, false))
      end

      it 'sends no for has_gcse_maths_and_english_id if they have passed English but not Maths GCSEs' do
        application_form.maths_gcse.update(grade: 'Z')

        expect_sign_up(has_gcse_maths_and_english_id: constants.fetch(:gcse, false))
      end

      it "sends no for has_gcse_science_id if they haven't got a Science GCSE" do
        application_form.science_gcse.destroy

        expect_sign_up(has_gcse_science_id: constants.fetch(:gcse, false))
      end

      it 'sends no for has_gcse_science_id if they have not passed their Science GCSE' do
        application_form.science_gcse.update(grade: 'Z')

        expect_sign_up(has_gcse_science_id: constants.fetch(:gcse, false))
      end

      it 'sends yes for planning_to_retake_gcse_maths_and_english_id if they are completing both Maths and English GCSEs' do
        application_form.maths_gcse.update(grade: 'Z', currently_completing_qualification: true)
        application_form.english_gcse.update(grade: 'Z', currently_completing_qualification: true)

        expect_sign_up(
          has_gcse_maths_and_english_id: constants.fetch(:gcse, false),
          planning_to_retake_gcse_maths_and_english_id: constants.fetch(:gcse, true),
        )
      end

      it 'sends yes for planning_to_retake_gcse_maths_and_english_id if they are have passed their Maths GCSE and are completing their English GCSE' do
        application_form.english_gcse.update(grade: 'Z', currently_completing_qualification: true)

        expect_sign_up(
          has_gcse_maths_and_english_id: constants.fetch(:gcse, false),
          planning_to_retake_gcse_maths_and_english_id: constants.fetch(:gcse, true),
        )
      end

      it 'sends yes for planning_to_retake_gcse_maths_and_english_id if they are have passed their English GCSE and are completing their Maths GCSE' do
        application_form.maths_gcse.update(grade: 'Z', currently_completing_qualification: true)

        expect_sign_up(
          has_gcse_maths_and_english_id: constants.fetch(:gcse, false),
          planning_to_retake_gcse_maths_and_english_id: constants.fetch(:gcse, true),
        )
      end

      it 'sends no for planning_to_retake_gcse_maths_and_english_id if they are completing their Maths GCSE and have not passed their English GCSE' do
        application_form.maths_gcse.update(grade: 'Z', currently_completing_qualification: true)
        application_form.english_gcse.update(grade: 'Z')

        expect_sign_up(
          has_gcse_maths_and_english_id: constants.fetch(:gcse, false),
          planning_to_retake_gcse_maths_and_english_id: constants.fetch(:gcse, false),
        )
      end

      it 'sends no for planning_to_retake_gcse_maths_and_english_id if they are completing their English GCSE and have not passed their Maths GCSE' do
        application_form.english_gcse.update(grade: 'Z', currently_completing_qualification: true)
        application_form.maths_gcse.update(grade: 'Z')

        expect_sign_up(
          has_gcse_maths_and_english_id: constants.fetch(:gcse, false),
          planning_to_retake_gcse_maths_and_english_id: constants.fetch(:gcse, false),
        )
      end

      it 'sends yes for planning_to_retake_gcse_science_id if they are completing their Science GCSE' do
        application_form.science_gcse.update(grade: 'Z', currently_completing_qualification: true)

        expect_sign_up(
          has_gcse_science_id: constants.fetch(:gcse, false),
          planning_to_retake_gcse_science_id: constants.fetch(:gcse, true),
        )
      end
    end
  end

  def expect_request_attributes(attributes, expected_attributes)
    expect(attributes).to include(expected_attributes)
  end

  def expect_sign_up(expected_attribute_overrides = {})
    perform

    expect(api_double).to have_received(:sign_up_teacher_training_adviser_candidate) do |request|
      request_attributes = Adviser::TeacherTrainingAdviserSignUpDecorator.new(request).attributes_as_snake_case
      expect_request_attributes(request_attributes, baseline_attributes.merge(expected_attribute_overrides))
      yield(request_attributes) if block_given?
    end
  end

  def baseline_attributes
    {
      email: application_form.candidate.email_address,
      first_name: application_form.first_name,
      last_name: application_form.last_name,
      date_of_birth: application_form.date_of_birth,
      address_telephone: application_form.phone_number,
      address_postcode: application_form.postcode,
      country_id: country.id,
      degree_subject: degree.subject,
      uk_degree_grade_id: constants.fetch(:uk_degree_grades, degree.grade),
      degree_status_id: constants.fetch(:degree_status, :studying),
      degree_type_id: constants.fetch(:degree_types, :domestic),
      has_gcse_maths_and_english_id: constants.fetch(:gcse, true),
      planning_to_retake_gcse_maths_and_english_id: constants.fetch(:gcse, false),
      has_gcse_science_id: constants.fetch(:gcse, true),
      planning_to_retake_gcse_science_id: constants.fetch(:gcse, false),
      preferred_teaching_subject_id: preferred_teaching_subject.id,
      preferred_education_phase_id: constants.fetch(:education_phases, :secondary),
      initial_teacher_training_year_id: this_year.id,
      accepted_policy_id: privacy_policy.id,
      type_id: constants.fetch(:types, :interested_in_teacher_training),
      channel_id: constants.fetch(:channels, :apply),
    }
  end
end

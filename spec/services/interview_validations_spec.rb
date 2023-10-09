require 'rails_helper'

RSpec.describe InterviewValidations do
  subject(:interview_validations) { described_class.new(interview:) }

  delegate :errors, to: :interview_validations

  let(:interview) { application_choice.interviews.first }
  let(:application_choice) { create(:application_choice, :interviewing, course_option:) }
  let(:course) { create(:course, :with_accredited_provider) }
  let(:provider) { course.provider }
  let(:course_option) { create(:course_option, course:) }

  def errors
    interview_validations.errors.map(&:message)
  end

  def error_message(error)
    I18n.t("activemodel.errors.models.interview_validations.attributes.#{error}")
  end

  context 'existing interview with no changes' do
    let(:interview) { create(:interview, :past_date_and_time, application_choice:) }

    it 'is valid even if date_and_time in the past' do
      expect(interview_validations).to be_valid(:update)
    end
  end

  context 'new interview' do
    let(:interview) do
      build(
        :interview,
        application_choice:,
        date_and_time: nil,
      )
    end

    it 'needs a date_and_time' do
      expect(interview_validations).not_to be_valid(:create)
      expect(errors).to contain_exactly(error_message('date_and_time.blank'))
    end

    it 'needs an application_choice' do
      interview.date_and_time = 3.days.from_now
      interview.application_choice = nil

      expect(interview_validations).not_to be_valid(:create)
      expect(errors).to contain_exactly(error_message('application_choice.blank'))
    end

    it 'needs a provider' do
      interview.date_and_time = 3.days.from_now
      interview.provider = nil

      expect(interview_validations).not_to be_valid(:create)
      expect(errors).to contain_exactly(error_message('provider.blank'))
    end

    it 'needs an appropriate provider' do
      interview.date_and_time = 3.days.from_now

      interview.provider = course.accredited_provider
      expect(interview_validations).to be_valid

      interview.provider = create(:provider)
      expect(interview_validations).not_to be_valid(:create)
      expect(errors).to contain_exactly(error_message('provider.training_or_ratifying_only'))
    end

    it 'needs a location' do
      interview.date_and_time = 3.days.from_now
      interview.location = nil

      expect(interview_validations).not_to be_valid(:create)
      expect(errors).to contain_exactly(error_message('location.blank'))
    end

    it 'with a date_and_time in the past is not valid' do
      interview.date_and_time = 3.days.ago

      expect(interview_validations).not_to be_valid(:create)
      expect(errors).to contain_exactly(error_message('date_and_time.in_the_past'))
    end

    it 'with a date_and_time in the future is valid' do
      interview.date_and_time = 3.days.from_now

      expect(interview_validations).to be_valid(:create)
    end
  end

  context 'update interview' do
    context 'setting required fields to nil' do
      context 'setting provider to nil' do
        it 'is not valid' do
          interview.provider = nil

          expect(interview_validations).not_to be_valid(:update)
          expect(errors).to contain_exactly(error_message('provider.blank'))
        end
      end

      context 'setting location to nil' do
        it 'is not valid' do
          interview.location = nil

          expect(interview_validations).not_to be_valid(:update)
          expect(errors).to contain_exactly(error_message('location.blank'))
        end
      end

      context 'setting location to > 10240 characters' do
        it 'is not valid' do
          interview.location = 'A' * 10241

          expect(interview_validations).not_to be_valid(:update)
          expect(errors).to contain_exactly(error_message('location.too_long'))
        end
      end

      context 'setting additional_details to nil' do
        it 'is valid' do
          interview.additional_details = nil

          expect(interview_validations).to be_valid(:update)
        end
      end

      context 'setting additional_details to > 10240 characters' do
        it 'is not valid' do
          interview.additional_details = 'A' * 10241

          expect(interview_validations).not_to be_valid(:update)
          expect(errors).to contain_exactly(error_message('additional_details.too_long'))
        end
      end
    end

    context 'provider' do
      context 'becomes the training provider' do
        let(:provider) { course.accredited_provider }

        it 'is valid' do
          interview.provider = course.provider

          expect(interview_validations).to be_valid(:update)
        end
      end

      context 'becomes the ratifying provider' do
        it 'is valid' do
          interview.provider = course.accredited_provider

          expect(interview_validations).to be_valid(:update)
        end
      end

      context 'becomes any other provider' do
        it 'is not valid' do
          interview.provider = create(:provider)

          expect(interview_validations).not_to be_valid(:update)
          expect(errors).to contain_exactly(error_message('provider.training_or_ratifying_only'))
        end
      end
    end

    context 'date_and_time' do
      context 'changes from future to past' do
        it 'is not valid' do
          interview.date_and_time = 5.days.ago

          expect(interview_validations).not_to be_valid(:update)
          expect(errors).to contain_exactly(error_message('date_and_time.moving_interview_to_the_past'))
        end
      end

      context 'changes from past to past' do
        let(:interview) { create(:interview, :past_date_and_time, application_choice:) }

        it 'is not valid' do
          interview.date_and_time -= 1.day

          expect(interview_validations).not_to be_valid(:update)
          expect(errors).to contain_exactly(error_message('date_and_time.in_the_past'))
        end
      end

      context 'changes from future to future' do
        it 'is valid' do
          interview.date_and_time += 1.day

          expect(interview_validations).to be_valid(:update)
        end
      end

      context 'changes from future to after RBD date' do
        it 'is not valid' do
          rbd_date = application_choice.reject_by_default_at
          interview.date_and_time = rbd_date + 1.second

          expect(interview_validations).to be_valid(:update)
        end
      end
    end
  end

  context 'cancel interview' do
    context 'without a cancellation reason' do
      it 'is not valid' do
        interview.cancelled_at = Time.zone.now

        expect(interview_validations).not_to be_valid(:cancel)
        expect(errors).to contain_exactly(error_message('cancellation_reason.blank'))
      end
    end

    context 'with a cancellation reason > 10240 characters' do
      it 'is not valid' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A' * 10241

        expect(interview_validations).not_to be_valid(:cancel)
        expect(errors).to contain_exactly(error_message('cancellation_reason.too_long'))
      end
    end

    context 'when interview is in the future' do
      it 'is valid' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A cancellation reason'

        expect(interview_validations).to be_valid(:cancel)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::ChangeCourseChoiceForm, :with_audited, type: :model do
  include CourseOptionHelpers

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_guidance) }
    it { is_expected.to validate_presence_of(:audit_comment_ticket) }
    it { is_expected.to validate_presence_of(:provider_code) }
    it { is_expected.to validate_presence_of(:course_code) }
    it { is_expected.to validate_presence_of(:study_mode) }
    it { is_expected.to validate_presence_of(:site_code) }

    context 'for an invalid zendesk link' do
      invalid_link = 'nonsense'
      it { is_expected.not_to allow_value(invalid_link).for(:audit_comment_ticket) }
    end

    context 'for an valid zendesk link' do
      valid_link = 'www.becomingateacher.zendesk.com/agent/tickets/example'
      it { is_expected.to allow_value(valid_link).for(:audit_comment_ticket) }
    end
  end

  describe '#save!' do
    context 'if the new course is already an existing choice' do
      it 'raises a CourseChoiceError error' do
        first_course_option = create(:course_option)
        second_course_option = create(:course_option, course: create(:course, funding_type: 'fee'))
        application_form = create(:application_form)
        application_choice_to_change = create(:application_choice, :awaiting_provider_decision, course_option: first_course_option, application_form:)
        create(:application_choice, :awaiting_provider_decision, course_option: second_course_option, application_form:)

        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice_to_change.id,
          provider_code: second_course_option.provider.code,
          course_code: second_course_option.course.code,
          study_mode: second_course_option.study_mode,
          site_code: second_course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect { form.save(application_choice_to_change.id) }.to raise_error(CourseChoiceError, 'This course option has already been taken')
      end
    end

    context 'if the provider code is not a valid entry' do
      let(:original_course_option) { create(:course_option) }
      let(:application_choice) do
        create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)
      end
      let(:course_option) { create(:course_option, study_mode: :full_time) }
      let(:zendesk_ticket) { 'https://becomingateacher.zendesk.com/agent/tickets/12345' }

      it 'raises a validation error' do
        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: '111',
          course_code: course_option.course.code,
          study_mode: course_option.course.study_mode,
          site_code: course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        form.save(application_choice.id)
        expect(form.errors[:provider_code]).to include('Enter a real provider code')
      end

      context 'if the provider code is too long' do
        it 'raises a validation error' do
          form = described_class.new(
            application_choice_id: application_choice.id,
            provider_code: '111ABC',
            course_code: course_option.course.code,
            study_mode: course_option.course.study_mode,
            site_code: course_option.site.code,
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true,
          )

          form.save(application_choice.id)
          expect(form.errors[:provider_code]).to include('Provider code must be 3 characters')
        end
      end

      context 'if the provider code contains lower case letters' do
        it 'raises a validation error' do
          form = described_class.new(
            application_choice_id: application_choice.id,
            provider_code: '11a',
            course_code: course_option.course.code,
            study_mode: course_option.course.study_mode,
            site_code: course_option.site.code,
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true,
          )

          form.save(application_choice.id)
          expect(form.errors[:provider_code]).to include(
            'Provider code can only contain upper case letters A to Z and numbers 0 to 9',
          )
        end
      end
    end

    context 'if the course code is not a valid entry' do
      let(:original_course_option) { create(:course_option) }
      let(:application_choice) do
        create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)
      end
      let(:course_option) { create(:course_option, study_mode: :full_time) }
      let(:zendesk_ticket) { 'https://zendesk.com/agent/tickets/12345' }

      it 'raises a validation error' do
        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: 'ZZZZ',
          study_mode: course_option.course.study_mode,
          site_code: course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        form.save(application_choice.id)
        expect(form.errors[:course_code]).to include(
          'The course associated with this code is not available with this training provider',
        )
      end

      context 'if the course code is too long' do
        it 'raises a validation error' do
          form = described_class.new(
            application_choice_id: application_choice.id,
            provider_code: course_option.provider.code,
            course_code: 'ZZZZZZZZ',
            study_mode: course_option.course.study_mode,
            site_code: course_option.site.code,
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true,
            )

          form.save(application_choice.id)
          expect(form.errors[:course_code]).to include('Course code must be 4 characters')
        end
      end

      context 'if the course code contains lower case letters' do
        it 'raises a validation error' do
          form = described_class.new(
            application_choice_id: application_choice.id,
            provider_code: course_option.provider.code,
            course_code: 'ZZZz',
            study_mode: course_option.course.study_mode,
            site_code: course_option.site.code,
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true,
            )

          form.save(application_choice.id)
          expect(form.errors[:course_code]).to include(
            'Course code can only contain upper case letters A to Z and numbers 0 to 9',
          )
        end
      end

      context 'when the course code is not valid for the recruitment cycle' do
        it 'raises a validation error' do
          form = described_class.new(
            application_choice_id: application_choice.id,
            provider_code: course_option.provider.code,
            course_code: course_option.course.code,
            study_mode: course_option.course.study_mode,
            site_code: course_option.site.code,
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true,
            recruitment_cycle_year: course_option.course.recruitment_cycle_year - 1,
          )

          form.save(application_choice.id)
          expect(form.errors[:course_code]).to include(
            'The course associated with this code is not available in this recruitment cycle year',
          )
        end
      end
    end

    context 'if the study mode is not valid of the given course' do
      let(:original_course_option) { create(:course_option) }
      let(:application_choice) do
        create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)
      end
      let(:course_option) { create(:course_option, study_mode: :full_time) }
      let(:zendesk_ticket) { 'https://zendesk.com/agent/tickets/12345' }

      it 'raises a validation error' do
        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: course_option.course.code,
          study_mode: :part_time,
          site_code: course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        form.save(application_choice.id)

        expect(form.errors[:study_mode]).to include(
          'This study mode is not available with this training provider at this site',
        )
      end

      context 'if the study mode is not valid for the given site' do
        it 'raises a validation error' do
          another_site = create(:site, provider: course_option.provider)

          form = described_class.new(
            application_choice_id: application_choice.id,
            provider_code: course_option.provider.code,
            course_code: course_option.course.code,
            study_mode: :part_time,
            site_code: another_site.code,
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true,
          )

          form.save(application_choice.id)

          expect(form.errors[:study_mode]).to include('This study mode is not available for this course')
        end
      end
    end

    context 'if the site code is not valid of the given course' do
      let(:original_course_option) { create(:course_option) }
      let(:application_choice) do
        create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)
      end
      let(:course_option) { create(:course_option, study_mode: :full_time) }
      let(:zendesk_ticket) { 'https://zendesk.com/agent/tickets/12345' }

      it 'raises a validation error' do
        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: course_option.course.code,
          study_mode: course_option.course.study_mode,
          site_code: 'ZZ',
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        form.save(application_choice.id)

        expect(form.errors[:site_code]).to include(
          'This site code is not available for this course and study mode.',
        )
      end

      context 'if the site code is too long' do
        it 'raises a validation error' do
          form = described_class.new(
            application_choice_id: application_choice.id,
            provider_code: course_option.provider.code,
            course_code: course_option.course.code,
            study_mode: course_option.course.study_mode,
            site_code: 'ZZZZ',
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true,
            )

          form.save(application_choice.id)

          expect(form.errors[:site_code]).to include(
            'Site code must be 2 characters',
          )
        end
      end

      context `if the site code contains lower case letters` do
        it 'raises a validation error' do
          form = described_class.new(
            application_choice_id: application_choice.id,
            provider_code: course_option.provider.code,
            course_code: course_option.course.code,
            study_mode: course_option.course.study_mode,
            site_code: 'Zz',
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true,
            )

          form.save(application_choice.id)

          expect(form.errors[:site_code]).to include(
            'Site code can only contain upper case letters A to Z',
          )
        end
      end

      context 'if the site code is not valid for the given study mode' do
        it 'raises a validation error' do
          another_site = create(:site, provider: course_option.provider, code: "QQ")

          form = described_class.new(
            application_choice_id: application_choice.id,
            provider_code: course_option.provider.code,
            course_code: course_option.course.code,
            study_mode: :part_time,
            site_code: another_site.code,
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true,
          )

          form.save(application_choice.id)

          expect(form.errors[:site_code]).to include('This site code is not available with this training provider')
        end
      end
    end

    context 'if the new provider is not on the interview' do
      it 'raises a ProviderInterviewError' do
        original_course_option = create(:course_option)
        application_choice = create(:application_choice, :interviewing, course_option: original_course_option)

        other_provider = create(:provider)
        other_course = create(:course, provider: other_provider)
        other_course_option = create(:course_option, course: other_course, study_mode: :full_time)
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: other_provider.code,
          course_code: other_course_option.course.code,
          study_mode: other_course_option.course.study_mode,
          site_code: other_course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect { form.save(application_choice.id) }.to raise_error(ProviderInterviewError)
      end
    end

    context 'if the new course details are correct' do
      it 'updates the application choice' do
        original_course_option = create(:course_option)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)

        course_option = create(:course_option)
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: course_option.course.code,
          study_mode: course_option.course.study_mode,
          site_code: course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice.id)).to be(true)

        expect(application_choice.reload.course.name).to eq course_option.course.name
        expect(application_choice.course.id).not_to eq original_course_option.course.id
        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end

    context 'if the new course details are for a previous recruitment cycle' do
      it 'updates the application choice' do
        original_course_option = create(:course_option, course: create(:course, recruitment_cycle_year: 2024))
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)

        course_option = create(:course_option, course: create(:course, recruitment_cycle_year: 2024))
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: course_option.course.code,
          study_mode: course_option.course.study_mode,
          site_code: course_option.site.code,
          recruitment_cycle_year: 2024,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice.id)).to be(true)

        expect(application_choice.reload.course.name).to eq course_option.course.name
        expect(application_choice.course.id).not_to eq original_course_option.course.id
        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end

    context 'if the existing course has a ske condition' do
      it 'removes the ske condition' do
        original_course_option = create(:course_option)
        offer_with_ske = create(:offer, :with_ske_conditions)
        application_choice = create(:application_choice, :offer, offer: offer_with_ske, course_option: original_course_option)

        course_option = create(:course_option, study_mode: :full_time, course: create(:course, funding_type: 'fee'))
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: course_option.course.code,
          study_mode: course_option.course.study_mode,
          site_code: course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice.id)).to be(true)

        expect(application_choice.reload.course.name).to eq course_option.course.name
        expect(application_choice.course.id).not_to eq original_course_option.course.id
        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
        expect(application_choice.reload.offer.ske_conditions).to be_empty
      end
    end
  end
end

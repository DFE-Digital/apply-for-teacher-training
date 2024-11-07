require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.change_course' do
    let(:application_choice) do
      create(
        :application_choice,
        original_course_option:,
        course_option: current_course_option,
        current_course_option:,
        site:,
        application_form: create(:application_form, first_name: 'Fred'),
      )
    end
    let(:email) { described_class.change_course(application_choice, original_course_option) }
    let(:original_course_option) do
      create(
        :course_option,
        course: create(
          :course,
          name: 'Mathematics',
          code: 'M101',
        ),
      )
    end
    let(:current_course_option) do
      create(
        :course_option,
        course: create(
          :course,
          :part_time,
          name: 'Geography',
          code: 'H234',
          provider:,
        ),
        site:,
      )
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

    let(:provider) do
      create(:provider,
             name: 'Best Training',
             code: 'B54')
    end

    it_behaves_like(
      'a mail with subject and content',
      'Course details changed for Mathematics (M101)',
      'greeting' => 'Dear Fred',
      'old course' => 'The details of your application to study Mathematics (M101) have been changed',
      'new details' => 'The new details are:',
      'provider' => 'Training provider: Best Training',
      'course' => 'Course: Geography (H234)',
      'location' => 'Location: First Road',
      'study mode' => 'Full time or part time: Part time',
    )
  end
end

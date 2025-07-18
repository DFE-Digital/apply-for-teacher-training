require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  before do
    magic_link_stubbing(candidate)
    email_log_interceptor_stubbing
  end

  describe '.application_rejected' do
    let(:application_choice) { build_stubbed(:application_choice, :rejected, rejection_reason: 'Missing your English GCSE', course_option:) }
    let(:email) { described_class.application_rejected(application_choice) }

    context 'when the candidate receives a rejection' do
      it_behaves_like(
        'a mail with subject and content',
        'Update on your application',
        'intro' => 'Thank you for your application to study Mathematics at Arithmetic College',
        'rejection reasons' => 'Missing your English GCSE',
        'realistic job preview heading' => 'Understand your professional strengths',
        'realistic job preview' => 'Try the realistic job preview tool',
        'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
      )
    end

    context 'when the candidate that submitted to an undergraduate application is rejected' do
      let(:application_choice) do
        build_stubbed(:application_choice, :insufficient_a_levels_rejection_reasons)
      end

      it_behaves_like(
        'a mail with subject and content',
        'Update on your application',
        'rejection reasons' => "Qualifications\r\n\r\n        ^ A levels do not meet course requirements:\r\n        ^\r\n        ^ No sufficient grade",
      )
    end
  end

  context 'when A level reason is given' do
    it 'does not show qualifications heading neither any tailored advice' do
      application_choice = create(:application_choice, :insufficient_a_levels_rejection_reasons)
      email = described_class.application_rejected(application_choice)

      expect(email.body).to have_no_text('Make sure you meet the qualifications criteria')
      expect(email.body).to have_text('^ # Qualifications ^ A levels do not meet course requirements: ^ ^ No sufficient grade')
    end
  end

  context 'when one reason is given' do
    it 'does not show qualifications heading, but shows other relevant content' do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'teaching_knowledge', label: 'Teaching knowledge, ability and interview performance', selected_reasons: [
            { id: 'safeguarding_knowledge', label: 'Safeguarding knowledge' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = described_class.application_rejected(application_choice)

      expect(email.body).to have_no_text('Improve your subject knowledge')
      expect(email.body).to have_no_text('Get classroom experience')

      expect(email.body).to have_text('You can improve your application by getting some classroom experience. This could be in a school, sports club or by observing classes online.').once
      expect(email.body).to have_text('Find out how to get school experience').once
    end
  end

  context 'when the rejection reasons is multiple missing GCSEs' do
    it 'treats multiple missing GCSEs as a single rejection reasons for tailored advice' do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'qualifications', label: 'Qualifications', selected_reasons: [
            { id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
            { id: 'no_english_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
            { id: 'no_science_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = described_class.application_rejected(application_choice)

      expect(email.body).to have_no_text('Make sure you meet the qualifications criteria')

      expect(email.body).to have_text('Find a course with a training provider that will accept an equivalency test or,').once
      expect(email.body).to have_text('take your GCSE exams if you do not have them or,').once
      expect(email.body).to have_text('retake them to improve your grades.').once
    end
  end

  context 'between cycles', time: after_apply_deadline do
    it 'does not render unsuitable_degree_subject content' do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'qualifications', label: 'Qualifications', selected_reasons: [
            { id: 'unsuitable_degree_subject', label: 'Degree subject does not meet course requirements' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = described_class.application_rejected(application_choice)

      expect(email.body).to have_no_text 'https://find-teacher-training-courses.service.gov.uk/'
      expect(email.body).to have_no_text 'make sure you check the degree subject requirements on the course you want to apply for.'
      expect(email.body).to have_no_text 'You can try searching for a course that matches the subject of your degree more closely.'
    end
  end

  context 'multiple reasons in one category are selected' do
    it 'renders the heading if multiple reasons in the same reason category are selected', time: mid_cycle do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'qualifications', label: 'Qualifications', selected_reasons: [
            { id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
            { id: 'no_english_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
            { id: 'no_science_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
            { id: 'no_degree', label: 'No bachelor’s degree or equivalent' },
            { id: 'already_qualified', label: 'Already has a teaching qualification' },
            { id: 'unsuitable_degree_subject', label: 'Degree subject does not meet course requirements' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = described_class.application_rejected(application_choice)

      expect(email.body).to have_text('Make sure you meet the qualifications criteria').once # Heading only rendered once

      # Gcse content
      expect(email.body).to have_text('Find a course with a training provider that will accept an equivalency test or,').once
      expect(email.body).to have_text('take your GCSE exams if you do not have them or,').once
      expect(email.body).to have_text('retake them to improve your grades.').once
      expect(email.body).to have_text('You could consider a different route into teaching.').once

      # Already qualified content
      expect(email.body).to have_text 'If you already hold qualified teacher status (QTS)'
      expect(email.body).to have_text 'search for teaching vacancies'
      expect(email.body).to have_text 'https://teaching-vacancies.service.gov.uk/'
      expect(email.body).to have_text 'https://teaching-vacancies.service.gov.uk/jobseeker-guides/return-to-teaching-in-england/return-to-teaching/'
      expect(email.body).to have_text 'https://getintoteaching.education.gov.uk/train-to-be-a-teacher/assessment-only-route-to-qts'
      expect(email.body).to have_text 'https://getintoteaching.education.gov.uk/non-uk-teachers/teach-in-england-if-you-trained-overseas'

      # Unsuitable degree content
      expect(email.body).to have_text 'https://find-teacher-training-courses.service.gov.uk/'
      expect(email.body).to have_text 'make sure you check the degree subject requirements on the course you want to apply for.'
      expect(email.body).to have_text 'You can try searching for a course that matches the subject of your degree more closely.'
    end
  end

  describe 'shows the same content for quality_of_writing and personal statement_other reasons' do
    it 'shows the personal_statement advice when qualify of writing is selected' do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'personal_statement', label: 'Personal statement', selected_reasons: [
            { id: 'quality_of_writing', label: 'Quality of writing' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = described_class.application_rejected(application_choice)

      expect(email.body).to have_no_text('Improve your personal statement') # heading not rendered when only one selection
      expect(email.body).to have_text('Get help').once
      expect(email.body).to have_text('Learn more about teacher training advisers').twice # In the footer as well as the advice
    end

    it 'shows personal statement advice when personal_statement_other is selected' do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'personal_statement', label: 'Personal statement', selected_reasons: [
            { id: 'personal_statement_other', label: 'Other' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = described_class.application_rejected(application_choice)

      expect(email.body).to have_no_text('Improve your personal statement') # heading not rendered when only one selection
      expect(email.body).to have_text('A teacher training adviser can provide free support to help you improve your personal statement.').once
      expect(email.body).to have_text('Learn more about teacher training advisers').twice # In the footer as well as the tailored advice
    end
  end

  describe 'multiple reasons' do
    it 'shows relevant content and headings if available' do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'communication_and_scheduling', label: 'Communication, interview attendance and scheduling', selected_reasons: [
            { id: 'did_not_reply', label: 'Did not reply to messages' },
          ] },
          { id: 'qualifications', label: 'Qualifications', selected_reasons: [
            { id: 'no_degree', label: "No bachelor's degree or equivalent" },
          ] },
          { id: 'teaching_knowledge', label: 'Teaching knowledge, ability and interview performance', selected_reasons: [
            { id: 'subject_knowledge', label: 'Subject knowledge' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = described_class.application_rejected(application_choice)

      expect(email.body).to have_text('Make sure you meet the qualifications criteria').once # qualification heading
      expect(email.body).to have_text('You could consider a different route into teaching.')

      expect(email.body).to have_text('Find out how to train to teach if you do not have a degree').once # no headings for communication and scheduling
      expect(email.body).to have_text('If you are ready to apply again, check your contact details are correct before you submit any more applications.').once
      expect(email.body).to have_text('If you change your mind about a course, you can withdraw your application.').once

      expect(email.body).to have_text('Improve your subject knowledge').once # teaching knowledge heading
      expect(email.body).to have_text('You may be able to do a subject knowledge enhancement (SKE) course to top up your subject knowledge. You could also find a course in a different subject, which may also involve a SKE course to prepare you to teach that subject.').once
      expect(email.body).to have_text('Find out if you’re eligible for a SKE course').once
    end
  end

  describe 'teaching knowledge reasons' do
    it 'treats all classroom experience related reasons as a single reasons' do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'teaching_knowledge', label: 'Teaching knowledge, ability and interview performance', selected_reasons: [
            { id: 'safeguarding_knowledge', label: 'Safeguarding knowledge' },
            { id: 'teaching_method_knowledge', label: 'Teaching method knowledge' },
            { id: 'teaching_role_knowledge', label: 'Teaching role knowledge' },
            { id: 'teaching_knowledge_other', label: 'Other' },
            { id: 'teaching_demonstration', label: 'Teaching demonstration' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = described_class.application_rejected(application_choice)

      expect(email.body).not_to have_text('Get classroom experience').once
      expect(email.body).to have_text('You can improve your application by getting some classroom experience. This could be in a school, sports club or by observing classes online.').once
      expect(email.body).to have_text('Find out how to get school experience').once
    end
  end

  describe 'communication interview attendance and scheduling reasons' do
    it 'shows all the individual content for selected reasons' do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'communication_and_scheduling', label: 'Communication, interview attendance and scheduling', selected_reasons: [
            { id: 'did_not_reply', label: 'Did not reply to messages' },
            { id: 'did_not_attend_interview', label: 'Did not attend interview' },
            { id: 'could_not_arrange_interview', label: 'Could not arrange interview' },
            { id: 'english_below_standard', label: 'English language ability below expected standard' },
            { id: 'communication_and_scheduling_other', label: 'Other' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = described_class.application_rejected(application_choice)

      # Did not reply advice
      expect(email.body).to have_text('If you are ready to apply again, check your contact details are correct before you submit any more applications.').once

      # Did not attend interview advice
      expect(email.body).to have_text('If you are offered an interview but cannot attend, you should let the training provider know in advance.').once

      # Could not arrange interview advice AND Did not reply advice AND Communication and scheduling other advice are the same, only rendered once
      expect(email.body).to have_text('If you are ready to apply again, check your contact details are correct before you submit any more applications.').once
      expect(email.body).to have_text('If you change your mind about a course, you can withdraw your application.').once

      # English below standard advice
      expect(email.body).to have_text 'Make sure your English meets the criteria'
      expect(email.body).to have_text 'You can take an English language proficiency test or an equivalency test to show that you meet the standard of a grade 4 General Certificate of Secondary Education (GCSE) in English.'
      expect(email.body).to have_text 'Find out about the qualifications you need to train to teach in England'
      expect(email.body).to have_text 'https://getintoteaching.education.gov.uk/non-uk-teachers/non-uk-qualifications'
    end
  end

  it 'does not show course_full heading if it is the only selected reason', time: mid_cycle do
    structured_rejection_reasons = {
      selected_reasons: [
        { id: 'course_full', label: 'Course full', details: { id: 'course_full_details', text: 'text' } },
      ],
    }

    application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
    email = described_class.application_rejected(application_choice)

    expect(email.body).not_to have_text('There are still courses with spaces available').once
    expect(email.body).to have_text('Search again for courses with available places').once
  end

  it 'shows content for the reasons that do not have nested reasons', time: mid_cycle do
    structured_rejection_reasons = {
      selected_reasons: [
        { id: 'course_full', label: 'Course full', details: { id: 'course_full_details', text: 'text' } },
        { id: 'other', label: 'Other', details: { id: 'other_details', text: 'text' } },
        { id: 'visa_sponsorship', label: 'Visa sponsorship', details: { id: 'visa_sponsorship_details', text: 'text' } },
        { id: 'safeguarding', label: 'Safeguarding', details: { id: 'safeguarding_details', text: 'text' } },
      ],
    }

    application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
    email = described_class.application_rejected(application_choice)

    # Course full
    expect(email.body).to have_text('There are still courses with spaces available').once
    expect(email.body).to have_text('Search again for courses with available places').once

    # Visa sponsorship
    expect(email.body).to have_text('Look for a training provider who will sponsor visas.').once
    expect(email.body).to have_text('Search for courses').once
    expect(email.body).to have_text('and then filter by ‘Only show courses with visa sponsorship’.').once

    # Safeguarding and Other (same content, just rendered once)
    expect(email.body).to have_text('It is worth looking at the feedback the course provider has given to understand why your application was not accepted. This will help you to decide on your next steps.').once
    expect(email.body).to have_text('Find out what to do if your application was unsuccessful').once
  end

  it 'shows the enic statement content' do
    structured_rejection_reasons = {
      selected_reasons: [
        { id: 'qualifications', label: 'Qualifications', selected_reasons: [
          { id: 'unverified_qualifications', label: 'Cant verify' },
          { id: 'unverified_equivalency_qualifications', label: 'Could not verify equivalency of qualifications' },
        ] },
      ],
    }

    application_form = create(:application_form, :minimum_info)
    application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:, application_form: application_form)
    create(:degree_qualification, enic_reference: nil, institution_country: 'FR', application_form: application_form)

    email = described_class.application_rejected(application_choice)

    expect(email.body).to have_text('Showing providers how your qualifications compare to UK ones with a statement of comparability makes you around 30% more likely to receive an offer.').once
    expect(email.body).not_to have_text('You should also be able to request a copy of your degree certificate from the organisation where you studied in the UK.').once
  end

  it 'shows content for domestic candidates for unverified qualifications reasons' do
    structured_rejection_reasons = {
      selected_reasons: [
        { id: 'qualifications', label: 'Qualifications', selected_reasons: [
          { id: 'unverified_qualifications', label: 'Cant verify' },
          { id: 'unverified_equivalency_qualifications', label: 'Could not verify equivalency of qualifications' },
        ] },
      ],
    }

    application_form = create(:application_form, :minimum_info)
    application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:, application_form: application_form)

    email = described_class.application_rejected(application_choice)

    expect(email.body).to have_text('get a certified statement of your exam results').once
    expect(email.body).to have_text('You should also be able to request a copy of your degree certificate from the organisation where you studied in the UK.').once
    expect(email.body).not_to have_text('Showing providers how your qualifications compare to UK ones with a statement of comparability makes you around 30% more likely to receive an offer.').once
  end

  describe 'tailored rejection reason for placements' do
    let(:structured_rejection_reasons) do
      {
        selected_reasons: [
          {
            id: 'school_placement',
            label: 'School placement',
            selected_reasons: [
              {
                id: 'no_placements',
                label: 'No available placements',
                details: { id: 'no_placements_details', text: 'Text the provider has written' },
              },
            ],
          },
        ],
      }
    end
    let(:application_form) { create(:application_form, :minimum_info) }
    let(:application_choice) { create(:application_choice, :rejected_reasons, structured_rejection_reasons:, application_form: application_form) }
    let(:email) { described_class.application_rejected(application_choice) }

    it 'shows the tailored rejection reason for placements mid cycle', time: mid_cycle do
      expect(email.body).to have_content 'Text the provider has written'
      expect(email.body).to have_content 'There are still courses with placements available'
      expect(email.body).to have_content 'If the course you applied to has no placements,'
      expect(email.body).to have_content 'you can search again'
      expect(email.body).to have_content 'https://find-teacher-training-courses.service.gov.uk/)'
      expect(email.body).to have_content 'You can try increasing the search radius or location to see more options.'
    end

    it 'only shows the free text between cycles', time: after_apply_deadline do
      expect(email.body).to have_content 'Text the provider has written'
      expect(email.body).to have_no_content 'There are still courses with placements available'
    end
  end

  describe 'tailored teacher training adviser text for "assigned" adviser status' do
    let(:application_form_with_adviser_eligibility) { create(:application_form_eligible_for_adviser, adviser_status: 'assigned') }
    let(:application_choice) { create(:application_choice, :rejected, application_form: application_form_with_adviser_eligibility) }

    subject(:email) { described_class.application_rejected(application_choice) }

    it 'refers to existing adviser' do
      expect(email.body).to have_content 'Your teacher training adviser can help you improve your application. They can support you with:'
      expect(email.body).to have_content 'making your application stronger before you apply again'
      expect(email.body).to have_content 'Contact your teacher training adviser to talk about your next steps.'
    end
  end

  describe 'tailored teacher training adviser text for non-assigned adviser status' do
    let(:application_choice) { create(:application_choice, :rejected) }

    subject(:email) { described_class.application_rejected(application_choice) }

    it 'refers to the process for getting an adviser' do
      expect(email.body).to have_content 'A teacher training adviser can provide free support to help you improve your application. They can support you with:'
      expect(email.body).to have_content 'All our advisers have years of teaching experience and know the application process inside and out.'
      expect(email.body).to have_content 'Learn more about teacher training advisers'
    end
  end

  describe 'Course Recommendations URL' do
    let(:application_choice) { create(:application_choice, :rejected) }

    context 'when a URL is not provided' do
      subject(:email) { described_class.application_rejected(application_choice) }

      it 'does not include the URL in the email body' do
        expect(email.body).to have_no_content 'Based on the details in your previous application, you could be suitable for other teacher training courses.'
        expect(email.body).to have_no_content 'View similar courses and apply'
        expect(email.body).to have_no_content 'https://find-teacher-training-courses.service.gov.uk/results'
      end
    end

    context 'when a URL is provided' do
      subject(:email) { described_class.application_rejected(application_choice, 'https://find-teacher-training-courses.service.gov.uk/results') }

      it 'includes the provided URL and content in the email body' do
        expect(email.body).to have_content 'Based on the details in your previous application, you could be suitable for other teacher training courses.'
        expect(email.body).to have_content 'View similar courses and apply'
        expect(email.body).to have_content 'https://find-teacher-training-courses.service.gov.uk/results'
      end

      context 'between cycles' do
        before do
          allow(RecruitmentCycleTimetable).to receive(:currently_between_cycles?).and_return(true)
        end

        it 'does not include the URL and content in the email body' do
          expect(email.body).to have_no_content 'Based on the details in your previous application, you could be suitable for other teacher training courses.'
          expect(email.body).to have_no_content 'View similar courses and apply'
          expect(email.body).to have_no_content 'https://find-teacher-training-courses.service.gov.uk/results'
        end
      end
    end
  end
end

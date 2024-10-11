require 'rails_helper'

RSpec.describe 'Tailored advice for rejected applications' do
  include TestHelpers::MailerSetupHelper

  context 'when A level reason is given' do
    it 'does not show qualifications heading neither any tailored advice' do
      application_choice = create(:application_choice, :insufficient_a_levels_rejection_reasons)
      email = CandidateMailer.application_rejected(application_choice)

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
      email = CandidateMailer.application_rejected(application_choice)

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
      email = CandidateMailer.application_rejected(application_choice)

      expect(email.body).to have_no_text('Make sure you meet the qualifications criteria')

      expect(email.body).to have_text('Find a course with a training provider that will accept an equivalency test or,').once
      expect(email.body).to have_text('take your GCSE exams if you do not have them or,').once
      expect(email.body).to have_text('retake them to improve your grades.').once
    end
  end

  context 'multiple reasons in one category are selected' do
    it 'renders the heading if multiple reasons in the same reason category are selected' do
      structured_rejection_reasons = {
        selected_reasons: [
          { id: 'qualifications', label: 'Qualifications', selected_reasons: [
            { id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
            { id: 'no_english_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
            { id: 'no_science_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
            { id: 'no_degree', label: 'No bachelor’s degree or equivalent' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = CandidateMailer.application_rejected(application_choice)

      expect(email.body).to have_text('Make sure you meet the qualifications criteria').once # Heading only rendered once

      expect(email.body).to have_text('Find a course with a training provider that will accept an equivalency test or,').once
      expect(email.body).to have_text('take your GCSE exams if you do not have them or,').once
      expect(email.body).to have_text('retake them to improve your grades.').once
      expect(email.body).to have_text('You could consider a different route into teaching.').once
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
      email = CandidateMailer.application_rejected(application_choice)

      expect(email.body).to have_no_text('Improve your personal statement') # heading not rendered when only one selection
      expect(email.body).to have_text('A teacher training adviser can provide free support to help you improve your personal statement.').once
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
      email = CandidateMailer.application_rejected(application_choice)

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
      email = CandidateMailer.application_rejected(application_choice)

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
      email = CandidateMailer.application_rejected(application_choice)

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
            { id: 'communication_and_scheduling_other', label: 'Other' },
          ] },
        ],
      }

      application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
      email = CandidateMailer.application_rejected(application_choice)

      # Did not reply advice
      expect(email.body).to have_text('If you are ready to apply again, check your contact details are correct before you submit any more applications.').once

      # Did not attend interview advice
      expect(email.body).to have_text('If you are offered an interview but cannot attend, you should let the training provider know in advance.').once

      # Could not arrange interview advice AND Did not reply advice AND Communication and scheduling other advice are the same, only rendered once
      expect(email.body).to have_text('If you are ready to apply again, check your contact details are correct before you submit any more applications.').once
      expect(email.body).to have_text('If you change your mind about a course, you can withdraw your application.').once
    end
  end

  it 'does not show course_full heading if it is the only selected reason', time: mid_cycle do
    structured_rejection_reasons = {
      selected_reasons: [
        { id: 'course_full', label: 'Course full', details: { id: 'course_full_details', text: 'text' } },
      ],
    }

    application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:)
    email = CandidateMailer.application_rejected(application_choice)

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
    email = CandidateMailer.application_rejected(application_choice)

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
        ] },
      ],
    }

    application_form = create(:application_form, :minimum_info)
    application_choice = create(:application_choice, :rejected_reasons, structured_rejection_reasons:, application_form: application_form)
    create(:degree_qualification, enic_reference: nil, institution_country: 'FR', application_form: application_form)

    email = CandidateMailer.application_rejected(application_choice)

    expect(email.body).to have_text('Showing providers how your qualifications compare to UK ones with a statement of comparability makes you around 30% more likely to receive an offer.').once
    expect(email.body).not_to have_text('You should also be able to request a copy of your degree certificate from the organisation where you studied in the UK.').once
  end
end

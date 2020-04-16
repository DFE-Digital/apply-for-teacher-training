# Returns an array of hashes, where each hash is in the format expected by
# UCAS as 'Dataset 1', defined in the Data Sharing Agreement between us
class ApplicationsExportForUCAS
  HEADER_NAMES = {
    apply_candidate_id: 'Apply candidate ID',
    first_name: 'First Name',
    surname: 'Surname',
    dob: 'DOB',
    address_line_1: 'Address line 1',
    address_line_2: 'Address line 2',
    address_line_3: 'Address line 3',
    address_line_4: 'Address line 4',
    country: 'Country',
    postcode: 'Postcode',
    email_address: 'Email address',
    provider_code: 'Provider code',
    provider_name: 'Provider name',
    phase: 'Phase',
    programme_type: 'Programme type',
    programme_outcome: 'Programme outcome',
    nctl_subject: 'NCTL subject',
    course_name: 'Course name',
    course_code: 'Course Code',
  }.freeze

  def applications
    relevant_applications.flat_map do |application_form|
      application_form.application_choices.map do |choice|
        convert_to_hash(choice)
      end
    end
  end

  # UCAS require the CSV header to have names which are not very
  # good as Hash keys, so we convert the first objects' keys to
  # those human-readable values here
  def self.csv_header(applications)
    applications.first.keys.map { |key| HEADER_NAMES[key] }
  end

private

  def relevant_applications
    ApplicationForm
      .includes(
        :candidate,
        :application_choices,
        :application_qualifications,
        :application_work_experiences,
        :application_references,
        application_choices: %i[course provider],
      )
      .where('candidates.hide_in_reporting' => false)
      .where.not(submitted_at: nil)
      .order('submitted_at asc')
  end

  def convert_to_hash(application_choice)
    form = application_choice.application_form
    {
      apply_candidate_id: form.candidate_id,
      first_name: form.first_name,
      surname: form.last_name,
      dob: form.date_of_birth.iso8601,
      address_line_1: form.address_line1,
      address_line_2: form.address_line2,
      address_line_3: form.address_line3,
      address_line_4: form.address_line4,
      country: form.country,
      postcode: form.postcode,
      email_address: form.candidate.email_address,
      provider_code: application_choice.provider.code,
      provider_name: application_choice.provider.name,
      phase: form.phase,
      programme_type: application_choice.course.funding_type,
      programme_outcome: application_choice.course.description,
      nctl_subject: subject_codes(application_choice.course),
      course_name: application_choice.course.name,
      course_code: application_choice.course.code,
    }
  end

  def subject_codes(course)
    course.subject_codes.to_a.join('|')
  end
end

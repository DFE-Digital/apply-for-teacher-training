require 'rails_helper'

RSpec.describe CandidateInterface::DegreeReviewComponent, type: :component do
  let(:application_form) { build_stubbed(:application_form) }
  let(:degree1) do
    build_stubbed(
      :degree_qualification,
      qualification_type: 'Bachelor of Arts in Architecture',
      qualification_level: 'bachelor',
      subject: 'Woof',
      institution_name: 'University of Doge',
      grade: 'Upper second',
      predicted_grade: false,
      start_year: '2005',
      award_year: '2008',
    )
  end
  let(:degree2) do
    build_stubbed(
      :degree_qualification,
      level: 'degree',
      qualification_type: 'Bachelor of Arts Economics',
      qualification_level: 'bachelor',
      subject: 'Meow',
      institution_name: 'University of Cate',
      grade: 'First',
      predicted_grade: true,
      start_year: '2007',
      award_year: '2010',
    )
  end

  let(:application_qualifications) { ActiveRecordRelationStub.new(ApplicationQualification, [degree1], scopes: [:degrees]) }

  before do
    allow(application_form).to receive(:application_qualifications).and_return(application_qualifications)
  end

  context 'when degrees are editable' do
    context 'when the degree has an abbreviation' do
      it 'renders the correct value on the summary card title' do
        result = render_inline(described_class.new(application_form:))

        expect(result).to have_css('.app-summary-card__title', text: 'BAArch Woof')
      end
    end

    context 'when the degree does not have an abbreviation' do
      let(:degree1) do
        build_stubbed(
          :degree_qualification,
          level: 'degree',
          qualification_type: 'BSc/Education',
          subject: 'Woof',
          grade: 'First class honours',
        )
      end

      it 'renders the correct value on the summary card title' do
        result = render_inline(described_class.new(application_form:))

        expect(result).to have_css('.app-summary-card__title', text: 'BSc/Education (Hons) Woof')
      end
    end

    it 'renders component with correct values for country' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.institution_country.review_label'),
        value: 'United Kingdom',
        action: {
          text: "Change #{t('application_form.degree.institution_country.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :country),
        },
      )
    end

    it 'renders component with correct values for a degree type' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.qualification_type.review_label'),
        value: 'Bachelor degree',
        action: {
          text: "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
        },
      )
    end

    context "when selection 'Another qualification equivalent to a degree' for uk degree which is a bachelor degree" do
      let(:qualification_type) { 'Bachelor of Arts in Architecture' }
      let(:degree1) do
        build_stubbed(
          :degree_qualification,
          qualification_type:,
          qualification_level: nil,
          subject: 'Woof',
          institution_name: 'University of Doge',
          grade: 'Upper second',
          predicted_grade: false,
          start_year: '2005',
          award_year: '2008',
        )
      end

      it 'renders component as a bachelor degree when equivalent is a bachelor' do
        allow(application_form).to receive(:application_qualifications).and_return(
          ActiveRecordRelationStub.new(ApplicationQualification, [degree1], scopes: [:degrees]),
        )

        component = render_inline(described_class.new(application_form:))
        expect(component).to summarise(
          key: 'Type of bachelor degree',
          value: 'Bachelor of Arts in Architecture',
          action: {
            text: "Change #{t('application_form.degree.type_of_degree.change_action', degree: 'bachelor degree')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
            href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :type),
          },
        )

        expect(component).to summarise(
          key: 'Degree type',
          value: 'Bachelor',
          action: {
            text: "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
            href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
          },
        )
      end

      context 'with case insensitive' do
        let(:qualification_type) { 'Bachelor of arts in architecture' }

        it 'renders component as a bachelor degree when equivalent is a bachelor' do
          allow(application_form).to receive(:application_qualifications).and_return(
            ActiveRecordRelationStub.new(ApplicationQualification, [degree1], scopes: [:degrees]),
          )

          component = render_inline(described_class.new(application_form:))
          expect(component).to summarise(
            key: 'Type of bachelor degree',
            value: 'Bachelor of arts in architecture',
            action: {
              text: "Change #{t('application_form.degree.type_of_degree.change_action', degree: 'bachelor degree')} for Bachelor of arts in architecture, Woof, University of Doge, 2008",
              href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :type),
            },
          )

          expect(component).to summarise(
            key: 'Degree type',
            value: 'Bachelor',
            action: {
              text: "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of arts in architecture, Woof, University of Doge, 2008",
              href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
            },
          )
        end
      end
    end

    context "when selection 'Another qualification equivalent to a degree' for uk degree is a bachelor degree" do
      let(:degree1) do
        build_stubbed(
          :degree_qualification,
          qualification_type: 'Bachelor of Arts in Architecture',
          qualification_level: nil,
          subject: 'Woof',
          institution_name: 'University of Doge',
          grade: 'Upper second',
          predicted_grade: false,
          start_year: '2005',
          award_year: '2008',
        )
      end

      it 'renders component as a bachelor degree when equivalent is a bachelor' do
        allow(application_form).to receive(:application_qualifications).and_return(
          ActiveRecordRelationStub.new(ApplicationQualification, [degree1], scopes: [:degrees]),
        )

        component = render_inline(described_class.new(application_form:))
        expect(component).to summarise(
          key: 'Type of bachelor degree',
          value: 'Bachelor of Arts in Architecture',
          action: {
            text: "Change #{t('application_form.degree.type_of_degree.change_action', degree: 'bachelor degree')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
            href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :type),
          },
        )

        expect(component).to summarise(
          key: 'Degree type',
          value: 'Bachelor',
          action: {
            text: "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
            href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
          },
        )
      end
    end

    context "when selection 'Another qualification equivalent to a degree' for uk degree is not a bachelor degree" do
      let(:degree1) do
        build_stubbed(
          :degree_qualification,
          qualification_type: 'Bachelor of Arts in Architecture and Potion making',
          qualification_level: nil,
          subject: 'Woof',
          institution_name: 'University of Doge',
          grade: 'Upper second',
          predicted_grade: false,
          start_year: '2005',
          award_year: '2008',
        )
      end

      it 'renders component as a bachelor degree when equivalent is a bachelor' do
        allow(application_form).to receive(:application_qualifications).and_return(
          ActiveRecordRelationStub.new(ApplicationQualification, [degree1], scopes: [:degrees]),
        )

        component = render_inline(described_class.new(application_form:))
        expect(component).to summarise(
          key: 'Degree type',
          value: 'Bachelor of Arts in Architecture and Potion making',
          action: {
            text: "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts in Architecture and Potion making, Woof, University of Doge, 2008",
            href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
          },
        )
      end
    end

    it 'renders component with correct values for a uk degree with equivalent bachelor degree' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: 'Type of bachelor degree',
        value: 'Bachelor of Arts in Architecture',
        action: {
          text: "Change #{t('application_form.degree.type_of_degree.change_action', degree: 'bachelor degree')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :type),
        },
      )

      expect(component).to summarise(
        key: 'Degree type',
        value: 'Bachelor degree',
        action: {
          text: "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
        },
      )
    end

    it 'renders component with correct values for a subject' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.subject.review_label'),
        value: 'Woof',
        action: {
          text: "Change #{t('application_form.degree.subject.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :subject),
        },
      )
    end

    it 'renders component with correct values for an institution' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.institution_name.review_label'),
        value: 'University of Doge',
        action: {
          text: "Change #{t('application_form.degree.institution_name.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :university),
        },
      )
    end

    it 'renders component with correct values for a start year' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.start_year.review_label'),
        value: '2005',
        action: {
          text: "Change #{t('application_form.degree.start_year.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :start_year),
        },
      )
    end

    it 'renders component with correct values for an award year' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.award_year.review_label'),
        value: '2008',
        action: {
          text: "Change #{t('application_form.degree.award_year.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :award_year),
        },
      )
    end

    context 'when the degree does not have a grade' do
      let(:degree1) do
        build_stubbed(
          :degree_qualification,
          level: 'degree',
          qualification_type: 'BSc/Education',
          subject: 'Woof',
          grade: nil,
          predicted_grade: false,
          start_year: '2007',
          award_year: '2008',
        )
      end

      it 'renders component with correct values for a grade' do
        component = render_inline(described_class.new(application_form:))
        expect(component).to summarise(
          key: t('application_form.degree.grade.review_label'),
          value: t('application_form.degree.review.not_specified'),
        )
      end
    end

    context 'when the degree does not have an award_year' do
      let(:degree1) do
        build_stubbed(
          :degree_qualification,
          level: 'degree',
          qualification_type: 'BSc/Education',
          subject: 'Woof',
          grade: 'First class honours',
          start_year: '2007',
          award_year: nil,
        )
      end

      it 'renders component with correct values for an award year' do
        component = render_inline(described_class.new(application_form:))
        expect(component).to summarise(
          key: t('application_form.degree.award_year.review_label'),
          value: t('application_form.degree.review.not_specified'),
        )
      end
    end

    it 'renders component with correct values for a known degree grade' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1, degree2], scopes: [:degrees]),
      )

      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.grade.review_label'),
        value: 'Upper second',
        action: {
          text: "Change #{t('application_form.degree.grade.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :grade),
        },
      )

      expect(component).to summarise(
        key: t('application_form.degree.grade.review_label_predicted'),
        value: 'First',
        action: {
          text: "Change #{t('application_form.degree.grade.change_action')} for Bachelor of Arts Economics, Meow, University of Cate, 2010",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree2, :grade),
        },
      )
    end

    it 'renders component with correct values for the completion status row' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1, degree2], scopes: [:degrees]),
      )

      result = render_inline(described_class.new(application_form:))

      completed_degree_summary = result.css('.app-summary-card').first
      predicted_degree_summary = result.css('.app-summary-card').last

      expect(extract_summary_row(completed_degree_summary, 'Have you completed this degree?').text).to include('Yes')
      expect(extract_summary_row(predicted_degree_summary, 'Have you completed this degree?').text).to include('No')
    end

    def extract_summary_row(element, title)
      element.css('.govuk-summary-list__row').find { |e| e.text.include?(title) }
    end

    it 'renders component with correct values for an other grade' do
      degree3 = build_stubbed(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts in Architecture',
        subject: 'Hoot',
        institution_name: 'University of Owl',
        grade: 'Third-class honours',
        predicted_grade: false,
        start_year: '2007',
        award_year: '2010',
      )

      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree3], scopes: [:degrees]),
      )

      component = render_inline(described_class.new(application_form:))
      expect(component).to have_css('.app-summary-card__title', text: 'BAArch (Hons) Hoot')
      expect(component).to summarise(
        key: t('application_form.degree.grade.review_label'),
        value: 'Third-class honours',
      )
    end

    it 'renders component with correct values for multiple degrees' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1, degree2], scopes: [:degrees]),
      )

      result = render_inline(described_class.new(application_form:))

      expect(result).to have_css('.app-summary-card__title', text: 'BAArch Woof')
      expect(result).to have_css('.app-summary-card__title', text: 'BAEcon Meow')
    end

    it 'renders component along with a delete link for each degree' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.app-summary-card__actions').text.strip).to include(
        "#{t('application_form.degree.delete')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
      )
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_degree_destroy_path(degree1),
      )
    end
  end

  context 'when the degree has been saved without setting the value of qualification_type' do
    let(:degree1) do
      build_stubbed(
        :degree_qualification,
        qualification_type: nil,
      )
    end

    it 'renders component with no value for degree type row' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: 'Degree type',
        value: '',
        action: {
          text: "Change #{t('application_form.degree.qualification.change_action')} for , #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
        },
      )
    end
  end

  context 'when the degree has been saved without setting the value of predicted_grade' do
    let(:degree1) do
      build_stubbed(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts in Architecture',
        subject: 'Woof',
        institution_name: 'University of Doge',
        grade: 'Upper second',
        predicted_grade: nil,
        start_year: '2005',
        award_year: '2008',
      )
    end

    it 'renders component with correct values for the completion status row' do
      allow(application_form).to receive(:application_qualifications).and_return(
        ActiveRecordRelationStub.new(ApplicationQualification, [degree1], scopes: [:degrees]),
      )

      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.completion_status.review_label'),
        value: '',
        action: {
          text: "Change #{t('application_form.degree.completion_status.change_action')} for Bachelor of Arts in Architecture, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :completed),
        },
      )
    end
  end

  context 'when degrees are editable and first degree is international' do
    let(:degree1) do
      build_stubbed(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        subject: 'Woof',
        institution_name: 'University of Doge',
        institution_country: 'DE',
        enic_reference: '0123456789',
        enic_reason: 'obtained',
        comparable_uk_degree: 'bachelor_honours_degree',
        grade: 'erste Klasse',
        predicted_grade: false,
        start_year: '2005',
        award_year: '2008',
        international: true,
      )
    end

    it 'renders component with correct values for an international institution' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.institution_name.review_label'),
        value: 'University of Doge',
        action: {
          text: "Change #{t('application_form.degree.institution_name.change_action')} for Bachelor of Arts, Woof, University of Doge, 2008",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :university),
        },
      )
    end

    it 'renders the unabbreviated value on the summary card title' do
      result = render_inline(described_class.new(application_form:))

      expect(result).to have_css('.app-summary-card__title', text: 'Bachelor of Arts Woof')
    end

    context 'when a UK ENIC reference number has been provided' do
      it 'renders component with correct values for UK ENIC statement' do
        component = render_inline(described_class.new(application_form:))
        expect(component).to summarise(
          key: t('application_form.degree.enic_statement.review_label'),
          value: 'Yes, I have a statement of comparability',
          action: {
            text: "Change #{t('application_form.degree.enic_statement.change_action')} for Bachelor of Arts, Woof, University of Doge, 2008",
            href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :enic),
          },
        )

        expect(component).to summarise(
          key: t('application_form.degree.enic_reference.review_label'),
          value: '0123456789',
          action: {
            text: "Change #{t('application_form.degree.enic_reference.change_action')} for Bachelor of Arts, Woof, University of Doge, 2008",
            href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :enic_reference),
          },
        )

        expect(component).to summarise(
          key: t('application_form.degree.comparable_uk_degree.review_label'),
          value: 'Bachelor (Honours) degree',
          action: {
            text: "Change #{t('application_form.degree.comparable_uk_degree.change_action')} for Bachelor of Arts, Woof, University of Doge, 2008",
            href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :enic_reference),
          },
        )
      end
    end

    context 'when the candidate has not provided a UK ENIC reference number' do
      let(:degree1) do
        build_stubbed(
          :degree_qualification,
          qualification_type: 'BA',
          subject: 'Woof',
          institution_name: 'University of Doge',
          institution_country: 'DE',
          enic_reference: '',
          comparable_uk_degree: nil,
          grade: 'erste Klasse',
          predicted_grade: false,
          start_year: '2005',
          award_year: '2008',
          international: true,
        )
      end

      it 'does not render a row for comparable UK degree and sets UK ENIC reference number to "Not provided"' do
        component = render_inline(described_class.new(application_form:))
        expect(component).to summarise(
          key: t('application_form.degree.enic_statement.review_label'),
          value: 'Not entered',
          action: {
            text: "Change #{t('application_form.degree.enic_statement.change_action')} for BA, Woof, University of Doge, 2008",
            href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :enic),
          },
        )

        expect(component).not_to summarise(
          key: t('application_form.degree.enic_reference.review_label'),
        )

        expect(component).not_to summarise(
          key: t('application_form.degree.comparable_uk_degree.review_label'),
        )
      end
    end
  end

  context 'when degrees are not editable and it is deletable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class.new(application_form:, editable: false, deletable: true))

      expect(result.text).not_to include('Change')
      expect(result.text).not_to include(t('application_form.degree.delete'))
    end
  end

  context 'when degrees are editable and it is deletable' do
    it 'renders component with an edit link' do
      result = render_inline(described_class.new(application_form:, editable: true, deletable: true))

      expect(result.text).to include('Change')
      expect(result.text).to include(t('application_form.degree.delete'))
    end
  end

  context 'degree is a uk degree type' do
    let(:degree1) do
      build_stubbed(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
      )
    end

    it 'renders a uk degree type row and changes value on type of degree row' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.type_of_degree.review_label', degree: 'bachelor degree'),
        value: 'Bachelor of Arts',
        action: {
          text: "Change #{t('application_form.degree.type_of_degree.change_action', degree: 'bachelor degree')} for Bachelor of Arts, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :type),
        },
      )

      expect(component).to summarise(
        key: t('application_form.degree.qualification_type.review_label'),
        value: 'Bachelor',
        action: {
          text: "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Arts, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
        },
      )
    end
  end

  context 'degree is not a uk degree type' do
    let(:degree1) do
      build_stubbed(
        :degree_qualification,
        qualification_type: 'Bachelor of Hogwarts Studies',
      )
    end

    it 'does not render a uk degree type row' do
      component = render_inline(described_class.new(application_form:))
      expect(component).not_to summarise(
        key: t('application_form.degree.type_of_degree.review_label', degree: 'Bachelor degree'),
        value: 'Bachelor of Hogwarts Studies',
        action: {
          text: "Change #{t('application_form.degree.type_of_degree.change_action')} for Bachelor of Hogwarts Studies, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :type),
        },
      )

      expect(component).to summarise(
        key: t('application_form.degree.qualification_type.review_label'),
        value: 'Bachelor of Hogwarts Studies',
        action: {
          text: "Change #{t('application_form.degree.qualification.change_action')} for Bachelor of Hogwarts Studies, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
        },
      )
    end
  end

  context 'doctorate degree' do
    let(:degree1) do
      create(
        :degree_qualification,
        qualification_type: 'Doctor of education',
        qualification_level: 'doctor',
      )
    end

    it 'render the doctorate degree' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.qualification_type.review_label'),
        value: 'Doctorate (PhD)',
        action: {
          text: "Change #{t('application_form.degree.qualification.change_action')} for Doctor of education, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :degree_level),
        },
      )

      expect(component).to summarise(
        key: 'Type of doctorate',
        value: 'Doctor of education',
        action: {
          text: "Change type of doctorate for Doctor of education, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :type),
        },
      )
    end

    it 'does not render a grade' do
      component = render_inline(described_class.new(application_form:))
      expect(component).not_to summarise(
        key: t('application_form.degree.grade.review_label'),
      )
    end
  end

  context 'an international degree' do
    let(:degree1) { create(:non_uk_degree_qualification, qualification_type: 'Diplôme') }

    it 'only renders degree type row' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.qualification_type.review_label'),
        value: 'Diplôme',
        action: {
          text: "Change #{t('application_form.degree.qualification.change_action')} for Diplôme, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :type),
        },
      )
    end

    it 'renders country row with correct value' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.institution_country.review_label'),
        value: 'France',
        action: {
          text: "Change #{t('application_form.degree.institution_country.change_action')} for Diplôme, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :country),
        },
      )
    end
  end

  context 'an incomplete international degree' do
    let(:degree1) { create(:non_uk_degree_qualification, predicted_grade: true) }

    it 'does not render the enic reference or comparable uk degree row' do
      component = render_inline(described_class.new(application_form:))
      expect(component).not_to summarise(
        key: t('application_form.degree.enic_reference.review_label'),
        value: degree1.enic_reference,
        action: {
          text: "Change #{t('application_form.degree.enic_reference.change_action')} for #{degree1.qualification_type}, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :enic),
        },
      )

      expect(component).not_to summarise(
        key: t('application_form.degree.comparable_uk_degree.review_label'),
        value: 'Bachelor (Ordinary) degree',
        action: {
          text: "Change #{t('application_form.degree.comparable_uk_degree.change_action')} for #{degree1.qualification_type}, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :enic),
        },
      )
    end
  end

  context 'a complete international degree' do
    let(:degree1) { create(:non_uk_degree_qualification, predicted_grade: false) }

    it 'renders the enic reference and comparable uk degree row' do
      component = render_inline(described_class.new(application_form:))
      expect(component).to summarise(
        key: t('application_form.degree.enic_reference.review_label'),
        value: degree1.enic_reference,
        action: {
          text: "Change #{t('application_form.degree.enic_reference.change_action')} for #{degree1.qualification_type}, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :enic_reference),
        },
      )

      expect(component).to summarise(
        key: t('application_form.degree.comparable_uk_degree.review_label'),
        value: 'Bachelor (Ordinary) degree',
        action: {
          text: "Change #{t('application_form.degree.comparable_uk_degree.change_action')} for #{degree1.qualification_type}, #{degree1.subject}, #{degree1.institution_name}, #{degree1.award_year}",
          href: Rails.application.routes.url_helpers.candidate_interface_degree_edit_path(degree1, :enic_reference),
        },
      )
    end
  end
end

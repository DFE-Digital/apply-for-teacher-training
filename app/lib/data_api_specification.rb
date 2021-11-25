class DataAPISpecification
  def self.as_yaml
    spec.to_yaml
  end

  def self.as_hash
    spec
  end

  def self.spec
    openapi = YAML.load_file('config/data-api.yml')

    tad_dataset = DataSetDocumentation.for(DataAPI::TADExport)
    tad_subject_domicile_nationality_dataset = DataSetDocumentation.for(DataAPI::TADSubjectDomicileNationalityExport)
    applications_dataset = DataSetDocumentation.for(SupportInterface::MinisterialReportApplicationsExport)
    candidates_dataset = DataSetDocumentation.for(SupportInterface::MinisterialReportCandidatesExport)
    applications_by_subject_route_grade_dataset = DataSetDocumentation.for(SupportInterface::ApplicationsBySubjectRouteAndDegreeGradeExport)
    applications_by_demographic_domicile_and_degree_class_dataset = DataSetDocumentation.for(SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport)

    openapi['components']['schemas']['TADExport']['properties'] = tad_dataset
    openapi['components']['schemas']['TADSubjectDomicileNationalityExport']['properties'] = tad_subject_domicile_nationality_dataset
    openapi['components']['schemas']['ApplicationsExport']['properties'] = applications_dataset
    openapi['components']['schemas']['CandidatesExport']['properties'] = candidates_dataset
    openapi['components']['schemas']['ApplicationsBySubjectRouteAndDegreeGradeExport']['properties'] = applications_by_subject_route_grade_dataset
    openapi['components']['schemas']['ApplicationsByDemographicDomicileAndDegreeClassExport']['properties'] = applications_by_demographic_domicile_and_degree_class_dataset

    openapi
  end
end

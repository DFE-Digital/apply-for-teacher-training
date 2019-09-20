task create_application_status_graph: :environment do
  application = CandidateApplication.new
  AASMDiagram::Diagram.new(application.aasm, 'tmp/application.png')
end

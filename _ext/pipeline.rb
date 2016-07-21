require_relative 'scan/repository.rb'

Awestruct::Extensions::Pipeline.new do

   extension Awestruct::Repository::Collector.new do
      collector Awestruct::Repository::FileCollector.new "_config/_repositories.yml"
      collector Awestruct::Ohloh::RepositoryCollector.new 
   end

   extension Awestruct::Repository::Processor.new do
      processor Awestruct::Repository::Cloner.new
      processor Arquillian::Processor::ReleasesReleases.new do 
         processor Arquillian::Processor::Maven.new do 
            
         end
         processor Arquillian::Processor::Gradle.new
      end
   end

end

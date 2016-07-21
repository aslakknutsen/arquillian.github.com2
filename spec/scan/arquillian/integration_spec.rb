require 'neo4j'
require 'spec_helper'

require_relative '../../../_ext/scan/arquillian/model.rb'
require_relative '../../../_ext/scan/arquillian.rb'
require_relative '../../../_ext/scan/arquillian/clone.rb'
require_relative '../../../_ext/scan/arquillian/artifact.rb'
require_relative '../../../_ext/scan/arquillian/maven.rb'
require_relative '../../../_ext/scan/arquillian/release.rb'
require_relative '../../../_ext/scan/arquillian/contributor.rb'

describe :integration do

   xit "complete" do
      1.times do |i|

         context = Arquillian::Scanner::Context.new :config
         context[:temp_folder] = "/tmp/arqtest"
         
         repository = context.new_child :repository
         repository[:clone_url] = "git://github.com/arquillian/arquillian-container-osgi.git"
         repository[:path] = "arquillian-container-osgi"
         repository[:relative_path] = ""

         processor = Arquillian::Processor::Clone.new(:clone) {
            #child Arquillian::Processor::Contributor.new(:contributor)
            child Arquillian::Processor::Release.new(:release) { 
               child Arquillian::Processor::Maven.new(:module) { 
            #      child Arquillian::Processor::Artifact.new(:artifact)
               }
            }
            child Arquillian::Processor::ContributorRelease.new(:contributor)
         }

         start = Time.now
         processor.process repository
         puts "#{i} -> #{Time.now - start} ms"

         #puts context.find_children :module
      end
   end
=begin
   describe "neo4j" do 
      before(:all) do
         @session = Neo4j::Session.open(
            :server_db,
            'http://localhost:7474',
            {
               basic_auth: {username: 'neo4j', password: 'test'}
            }
         )
      end

      after(:all) do
         @session.close
      end
      
      it "complete with neo" do

         context = Arquillian::Scanner::Context.new :config
         context[:temp_folder] = "/tmp/arqtest"
         
         repository = context.new_child :repository
         repository[:clone_url] = "git://github.com/arquillian/arquillian-core.git"
         repository[:path] = "arquillian-core"
         repository[:relative_path] = ""

         processor = Arquillian::Processor::Clone.new(:clone) {
            #child Arquillian::Processor::Contributor.new(:contributor)
            child Arquillian::Processor::Release.new(:release) { 
               child Arquillian::Processor::Maven.new(:module) { 
                  child Arquillian::Processor::Artifact.new(:artifact)
               }
            }
            #child Arquillian::Processor::ContributorRelease.new(:contributor)
            child Arquillian::Processor::ContributorModule.new(:contributor)
         }

         processor.process repository
         
         start = Time.now
         context.find_children(:repository).each do |repository|

            repo_node = Arquillian::Model::Repository.find_or_create_by(
               :clone_url => repository[:clone_url],
               :type => 'git'
            )

            repository.find_children(:contributor).each do |contributor|
               contributor_node = Arquillian::Model::User.find_or_create_by(
                  :name => contributor[:name],
                  :email => contributor[:email]
               )
              
            end

            repository.find_children(:release).each do |release|

               release_node = Arquillian::Model::Release.find_or_create_by(
                  :sha => release[:sha]
               ) do |n|
                  n.version = release[:name]
                  n.release_date = release[:date]
               end

               repo_node.releases << release_node

               release_node.released_by = Arquillian::Model::User.find_by(email: release[:released_by][:email])

               release.find_children(:module).each do |mod|

                  module_node = Arquillian::Model::Module.find_or_create_by(
                     :group_id => mod[:group_id],
                     :artifact_id => mod[:artifact_id])
                  
                  module_node.name = mod[:name]
                  module_node.type = mod[:packaging]
                  module_node.save #figure out changed / dirty state ?

                  mod.find_children(:artifact).each do |artifact|

                     artifact_node = Arquillian::Model::Artifact.find_or_create_by(
                        :group_id => mod[:group_id],
                        :artifact_id => mod[:artifact_id],
                        :type => mod[:packaging]
                     )
                     module_node.artifacts << artifact_node
                  end

                  module_release_node = Arquillian::Model::ModuleRelease.find_or_create_by(
                     :version => release[:name],
                     :group_id => mod[:group_id],
                     :artifact_id => mod[:artifact_id]
                  ) do |n|
                     n.path = mod[:relative_path]
                  end

                  module_release_node.module = module_node
                  module_release_node.release = release_node

                  mod.find_children(:contributor).each do |contributor|
                     module_release_node.contributors << Arquillian::Model::User.find_by(email: contributor[:email])
                  end
               end

            end
         end
         puts "#{Time.now - start} ms"
      end

      it "" do
         puts Arquillian::Model::ModuleRelease.methods
      end
   end
=end
end
module Arquillian
   module Processor
   
      module ContributorSupport

         def extract_contributors(commit, contributors)
            unless commit.actor.nil?
               contributors << {:name => commit.actor.name, :email => commit.actor.email}
            end

            unless commit.committer.nil?
               contributors << {:name => commit.committer.name, :email => commit.committer.email}
            end

            #inst, dels, chunks = commit.stats
         end

         def process_contributors(parent_context, contributors)
            contributors.each do |contributor|
               contrib_context = parent_context.new_child :contributor
               contrib_context[:name] = contributor[:name]
               contrib_context[:email] = contributor[:email]

               process_children contrib_context
            end
         end
      end

      # Thid adds no new info, should be an after prceossor?
      class Contributor < Arquillian::Scanner::Processor
         include Arquillian::Processor::ContributorSupport
         
         def work(parent_context) 

            client         = parent_context.requires_parent :clone, :client
            relative_path  = parent_context.find_parent :repository, :relative_path
            relative_path  = nil if relative_path.nil? or "".eql? relative_path

            contributors = Set.new
            client.git.log(relative_path).each do |commit|
               extract_contributors commit, contributors
            end

            process_contributors parent_context, contributors
         end

      end

      class ContributorRelease < Arquillian::Scanner::Processor
         include Arquillian::Processor::ContributorSupport
         
         def work(parent_context) 

            client         = parent_context.requires_parent :clone, :client
            relative_path  = parent_context.find_parent :repository, :relative_path
            relative_path  = nil if relative_path.nil? or "".eql? relative_path

            releases       = parent_context.find_children(:release)

            prev_release = nil

            releases.each do |release|

               contributors = Set.new
               if prev_release.nil?
                  client.git.log(relative_path, "#{release[:name]}^{}").each do |commit|
                     extract_contributors commit, contributors
                  end
               else
                  client.git.log_range(relative_path, "#{prev_release}^{}", "#{release[:name]}^{}").each do |commit|
                     extract_contributors commit, contributors
                  end
               end
               prev_release = release[:name]

               process_contributors release, contributors
            end
         end

      end

      class ContributorModule < Arquillian::Scanner::Processor
         include Arquillian::Processor::ContributorSupport
         
         def work(parent_context) 

            client         = parent_context.requires_parent :clone, :client
            relative_path  = parent_context.find_parent :module, :path
            relative_path  = parent_context.find_parent :repository, :relative_path
            relative_path  = nil if relative_path.nil? or "".eql? relative_path

            releases       = parent_context.find_children(:release)

            prev_release = nil

            releases.each do |release|

               modules = release.find_children(:module)
               modules.each do |mod|
                  contributors = Set.new
                  path = "#{relative_path}/#{mod[:path]}"
                  path = nil if "/".eql? path
                  if prev_release.nil?
                     client.git.log(path, "#{release[:name]}^{}").each do |commit|
                        extract_contributors commit, contributors
                     end
                  else
                     client.git.log_range(path, "#{prev_release}^{}", "#{release[:name]}^{}").each do |commit|
                        extract_contributors commit, contributors
                     end
                  end
                  process_contributors mod, contributors
               end
               prev_release = release[:name]
            end
         end

      end

   end
end
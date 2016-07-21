require 'rjgit'

module Arquillian
   module Processor

      class Clone < Arquillian::Scanner::Processor

         def work(parent_context)

            temp_folder    = parent_context.requires_parent :config, :temp_folder
            clone_url      = parent_context.requires_parent :repository, :clone_url
            output_path    = parent_context.requires_parent :repository, :path

            context = parent_context.new_child :clone

            target = "#{temp_folder}/#{output_path}"
            repo = nil
            if File.exists? target
               #puts "Using repository #{target}"
               repo = RJGit::Repo.new(target)
            else
               puts "Cloning repository #{clone_url}"
               repo = RJGit::RubyGit.clone(clone_url, target)
            end

            #puts "set transitive client"
            context.transitive(:client, repo)

            process_children context
         end

      end

   end
end
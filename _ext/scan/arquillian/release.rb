module Arquillian
   module Processor

      class Release < Arquillian::Scanner::Processor

         def work(context)
            #puts "In Release #{context.name}"

            client = context.requires_parent :clone, :client

            # Only select release tags
            releases = client.tags.select do |tag|
               tag =~ /.*/
            end

            releases.each_value do |release|
               
               puts "Release #{release.name}"

               next unless release.name =~ /^([a-z]+-?)?[0-9]\d*\.\d+(\.\d+)?([\.-]((alpha|beta|cr)-?[1-9]\d*|final))?$/i
               release_context = context.new_child :release
               release_context[:sha] = release.id
               release_context[:name] = release.name
               release_context[:date] = release.jtag.tagger_ident.when.time
               release_context[:released_by] = {}
               release_context[:released_by][:name] = release.actor.name
               release_context[:released_by][:email] = release.actor.email
               
               process_children release_context

            end
         end

      end
   end
end
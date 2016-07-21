require 'rexml/document'
require 'nokogiri'

module Arquillian
   module Processor
   
      class Maven < Arquillian::Scanner::Processor
         
         def work(parent_context) 
            
            client         = parent_context.requires_parent :clone, :client
            tag            = parent_context.requires_parent :release, :name
            relative_path  = parent_context.requires_parent :repository, :relative_path

            traverse_modules(client, tag, relative_path) do |path, pom|
            
               puts "Module #{pom.root.xpath("artifactId").text} #{path}"

               root = pom.root

               context = parent_context.new_child :module

               # Only keep parsed POM Object around for children
               context.transitive(:pom, pom)

               context[:group_id]       = text(nil, root, 'groupId', 'parent/groupId')
               context[:artifact_id]    = text(nil, root, 'artifactId')
               context[:version]       = text(nil, root, 'version', 'parent/version')
               context[:description]   = text('', root, 'description')
               context[:packaging]     = text('jar', root, 'packaging')
               context[:name]          = root.xpath("name").text

               context[:relative_path] = path.gsub('pom.xml', '')

               if root.xpath('licenses').size > 0
                  context[:license] = {}
                  context[:license][:name] = root.xpath('licenses/license/name').text
                  context[:license][:url] = root.xpath('licenses/license/url').text
               end

               if root.xpath('issueManagement').size > 0
                  context[:issueManagement] = {}
                  context[:issueManagement][:name] = root.xpath('issueManagement/system').text
                  context[:issueManagement][:url] = root.xpath('issueManagement/url').text
               end

               process_children context
            end

         end

         def text(default_value, root, *expressions)
            expressions.each do |exp|
               val = root.at_xpath(exp)
               return val.text unless val.nil?
            end
            return default_value
         end


         private

         def traverse_modules(client, rev, path)
            pompath = "#{path}pom.xml"
            blob = nil
            begin
               blob = client.blob(pompath, rev)
               return if blob.nil?
               #pomrev = client.revparse("#{rev}pom.xml")
            rescue
               puts "info: missing pom.xml in #{rev}"
               return
            end
            pom = Nokogiri::XML(blob.data)
            pom.remove_namespaces!

            yield pompath, pom
            
            unique_modules = Set.new
            pom.xpath('//modules/module').each do |mod|
               unique_modules << mod.text()
            end
            unique_modules.each do |submodule|
               traverse_modules(client, rev, "#{path}#{submodule}/") { |y, x| yield(y, x)}
            end
         end

      end

   end
end
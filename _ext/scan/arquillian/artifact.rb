module Arquillian
   module Processor
   
      # Thid adds no new info, should be an after prceossor?
      class Artifact < Arquillian::Scanner::Processor
         
         def work(parent_context) 

            version     = parent_context.requires_parent :release, :name

            groupId     = parent_context.requires_parent :module, :group_id
            artifactId  = parent_context.requires_parent :module, :artifact_id
            packaging   = parent_context.requires_parent :module, :packaging


            return unless artifactId =~ /.*bom|.*depchain.*|graphene/ or packaging == 'jar'
            return if artifactId =~/.*(ftest.*|inttest|example.*|build|build-config|build-resources)/
            return unless packaging == 'pom' || 'jar'

            artifact = parent_context.new_child :artifact
            artifact[:version] = version
            artifact[:group_id] = groupId
            artifact[:artifact_id] = artifactId
            artifact[:packaging] = packaging

            process_children artifact
         end

      end
   end
end
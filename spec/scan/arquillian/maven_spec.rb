require 'rjgit'
require 'spec_helper'

require_relative '../../../_ext/scan/arquillian.rb'
require_relative '../../../_ext/scan/arquillian/maven.rb'

describe Arquillian::Processor::Maven do
   
   process do
      context = Arquillian::Scanner::Context.new :config
      context[:temp_folder] = "/tmp/arqtest"
      
      repository = context.new_child :repository
      repository[:path] = "arquillian-cube" #just required for Clone
      repository[:relative_path] = ""

      clone = repository.new_child :clone
      clone[:client] = RJGit::Repo.new("#{context[:temp_folder]}/#{repository[:path]}")

      release = clone.new_child :release
      release[:name] = "1.0.0.Alpha5"


      start = Time.now
      Arquillian::Processor::Maven.new(:module).process release
      context
   end

   in_context :module do

      it { is_expected.to have_key :name,       eql("Arquillian Cube Extension") }
      it { is_expected.to have_key :packaging,  eql("pom") }

   end

end
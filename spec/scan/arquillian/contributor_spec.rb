require 'rjgit'
require 'spec_helper'

require_relative '../../../_ext/scan/arquillian.rb'
require_relative '../../../_ext/scan/arquillian/contributor.rb'

describe Arquillian::Processor::Contributor do
   
   process do
      context = Arquillian::Scanner::Context.new :config
      context[:temp_folder] = "/tmp/arqtest"
      
      repository = context.new_child :repository
      repository[:path] = "arquillian-cube" #just required for Clone
      repository[:relative_path] = ""

      clone = repository.new_child :clone
      clone[:client] = RJGit::Repo.new("#{context[:temp_folder]}/#{repository[:path]}")

      Arquillian::Processor::Contributor.new(:contributor).process clone
      context
   end

   it "test" do
      puts @context.find_children(:contributor)

   end

end

describe Arquillian::Processor::ContributorRelease do
   
   process do
      context = Arquillian::Scanner::Context.new :config
      context[:temp_folder] = "/tmp/arqtest"
      
      repository = context.new_child :repository
      repository[:path] = "arquillian-cube" #just required for Clone
      repository[:relative_path] = ""

      clone = repository.new_child :clone
      clone[:client] = RJGit::Repo.new("#{context[:temp_folder]}/#{repository[:path]}")

      ["1.0.0.Alpha1", "1.0.0.Alpha2", "1.0.0.Alpha3", "1.0.0.Alpha4", "1.0.0.Alpha4"].each do |r|

         release1 = clone.new_child :release
         release1[:name] = r
      end

      Arquillian::Processor::ContributorRelease.new(:contributor).process clone
      context
   end

   it "test" do
      puts @context.find_children :release
   end

end
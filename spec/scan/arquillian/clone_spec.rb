require_relative '../../../_ext/scan/arquillian.rb'
require_relative '../../../_ext/scan/arquillian/clone.rb'

describe Arquillian::Processor::Clone do
   
   it "clone a Repository via :clone_url" do

      context = Arquillian::Scanner::Context.new :config
      context[:temp_folder] = "/tmp/arqtest"
      
      repository = context.new_child :repository
      repository[:clone_url] = "git://github.com/arquillian/arquillian-cube.git"
      repository[:path] = "arquillian-cube"

      context = Arquillian::Processor::Clone.new(:clone).process repository

      expect(File.exists? "/tmp/arqtest/arquillian-cube").to be true

      expect(context.find_children(:clone).first).not_to be_nil 
      expect(context.find_children(:clone).first[:client]).not_to be_nil 

   end
end
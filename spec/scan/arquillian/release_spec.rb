require_relative '../../../_ext/scan/arquillian.rb'
require_relative '../../../_ext/scan/arquillian/clone.rb'
require_relative '../../../_ext/scan/arquillian/release.rb'

describe Arquillian::Processor::Release do
   
   it "Should be able to find all releases in a cloned Repository" do

      context = Arquillian::Scanner::Context.new :config
      context[:temp_folder] = "/tmp/arqtest"
      
      repository = context.new_child :repository
      repository[:clone_url] = "git://github.com/arquillian/arquillian-cube.git"
      repository[:path] = "arquillian-cube"

      context = Arquillian::Processor::Clone.new(:clone) {
         child Arquillian::Processor::Release.new :release
      }.process repository

      clone = context.find_children :clone

      expect(clone.children.size).to be > 4

   end
end
=begin

require 'neo4j'

#require_relative '../../_ext/scan/arquillian/model.rb'

describe Arquillian::Model do

   before(:all) do
      @session = Neo4j::Session.open(
         :server_db,
         'http://localhost:7474',
         {
            basic_auth: {username: 'neo4j', password: 'test'}
         }
      )
   end

   describe Arquillian::Model::Repository do

      it "should be able to create reposiotry" do

         Arquillian::Model::Repository.create({:clone_url => 'git://github.com/arquillian/arquillian-cube.git'})

      end

   end
end
=end

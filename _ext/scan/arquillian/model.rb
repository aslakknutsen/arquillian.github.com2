require 'neo4j'

module Arquillian

   module Model

      class Repository
      end

      class Module
      end

      class ModuleRelease
      end

      class Release
      end

      class User
      end

      class Artifact
      end

      class Repository
         include Neo4j::ActiveNode

         property :clone_url, index: :exact
         property :view_url
         property :organization

         property :type

         has_many :out, :releases, type: 'found_in', unique: true, model_class: Arquillian::Model::Release
         # type, clone_url, view_url, org

      end

      class Module
         include Neo4j::ActiveNode

         id_property :gav, on: :groupid_and_artifactid

         #property :name
         property :group_id
         property :artifact_id
         property :name
         property :description
         property :type

         has_many :out, :module_releases, type: 'released_in', model_class: Arquillian::Model::ModuleRelease
         has_many :in, :artifacts, type: 'published_by', unique: true, model_class: Arquillian::Model::Artifact
         
         #has_one :license

         # name, type, lead, license, releases[], repository

         def groupid_and_artifactid
            "#{group_id}:#{artifact_id}"
         end
      end

      class ModuleRelease
         include Neo4j::ActiveNode

         id_property :id, on: :groupid_and_artifactid_and_version

         property :group_id
         property :artifact_id
         property :version

         property :path

         def groupid_and_artifactid_and_version
            "#{group_id}:#{artifact_id}:#{version}"
         end

         has_one :in, :release, type: 'released_in', model_class: Arquillian::Model::Release
         has_one :out, :module, type: 'released_in', model_class: Arquillian::Model::Module
         has_many :in, :contributors, type: 'contributed_to', unique: true, model_class: Arquillian::Model::User

      end

      class Release
         include Neo4j::ActiveNode

         #property :name, index: :exact
         property :sha, index: :exact
         property :version, index: :exact
         property :release_date
         
         has_one :out, :repository, type: 'found_in', model_class: Arquillian::Model::Repository
         has_one :out, :released_by, type: 'released_by', model_class: Arquillian::Model::User 
         has_many :in, :module_releases, type: 'released_in', unique: true, model_class: Arquillian::Model::ModuleRelease

         # name, date, artifacts[], released_by
      end


      class Artifact
         include Neo4j::ActiveNode

         id_property :gav, on: :groupid_and_artifactid

         property :group_id
         property :artifact_id
         property :type

         has_many :out, :published_by, type: 'published_by', unique: true, model_class: Arquillian::Model::Module

         def groupid_and_artifactid
            "#{group_id}:#{artifact_id}"
         end
      end

      class User
         include Neo4j::ActiveNode

         property :github_id, index: :exact
         property :jbossorg_id, index: :exact
         property :email, index: :exact
         property :name
         property :description
         property :blog_url
         property :twitter_handle, index: :exact
         property :location
         property :company

         #has_many :roles

         # github_id, name, gravatar, description, twitter, blog, roles[], location, company

      end

      class Role
         include Neo4j::ActiveNode

         property :name
         property :type
      end

      class Event
         include Neo4j::ActiveNode

         property :name
         property :location
         property :start_date
         property :end_date

         #has_many :participents
      end

   end

end
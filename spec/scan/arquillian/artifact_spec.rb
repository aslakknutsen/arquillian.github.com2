require 'spec_helper'

require_relative '../../../_ext/scan/arquillian.rb'
require_relative '../../../_ext/scan/arquillian/artifact.rb'

describe Arquillian::Processor::Artifact do
   
   process do
      context = Arquillian::Scanner::Context.new :config

      release = context.new_child :release
      release[:name] = "1.0.0.Alpha5"

      mod = release.new_child :module
      mod[:group_id]     = "org.arquillian.cube"
      mod[:artifact_id]  = "arquillian-cube-docker"
      mod[:packaging]   = "jar"

      Arquillian::Processor::Artifact.new(:artifact).process mod
      context
   end

   in_context :artifact do

      it { is_expected.to have_key :group_id,    eql("org.arquillian.cube") }
      it { is_expected.to have_key :artifact_id, eql("arquillian-cube-docker") }
      it { is_expected.to have_key :packaging,  eql("jar") }
      it { is_expected.to have_key :version,    eql("1.0.0.Alpha5") }

   end


end
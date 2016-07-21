require 'spec_helper'

require_relative '../../_ext/scan/arquillian.rb'

describe Arquillian::Scanner do

   class TestProcessor < Arquillian::Scanner::Processor
      def work(context)
         child = context.new_child @name
         child["#{@name}_key"] = "#{@name}_value"
         child.transitive "#{name}_trans", "trans"
         process_children child
      end
   end

   class TestMultiProcessor < Arquillian::Scanner::Processor
      def work(context)
         ['1.0.0', '1.1.0'].each do |v|
            sub_context = context.new_child @name
            sub_context["#{@name}_key"] = "#{@name}_value"
            process_children sub_context
         end
      end
   end

   describe Arquillian::Scanner::Processor do

      subject(:context) do
         processor = TestProcessor.new(:parent) {
            child TestProcessor.new(:a) {
               child TestMultiProcessor.new(:b)
            }
            child TestProcessor.new(:c)
         }
         processor.process
      end
      it { is_expected.to have_child :parent }
      it { is_expected.to have_child :a }
      it { is_expected.to have_child :b }
      it { is_expected.to have_child :c }
      it { expect(context.find_children(:a).first.children.size).to eql 2 }
      it { expect(context.find_children(:parent).first[:parent_trans.to_s]).to be_nil }
   end
      
   describe Arquillian::Scanner::Context do

      describe :find_child do
         subject(:context) do
            parent = Arquillian::Scanner::Context.new :root
            parent.transitive(:key, :test)
            child1 = parent.new_child :child1
            child11 = child1.new_child :child11
            child2 = parent.new_child :child2

            parent
         end
      
         it { is_expected.to have_parent :root }
         it { expect(context.find_parent(:root)[:key]).to be :test }
         it { is_expected.to have_child :child2 }
      end

      describe :find_children do

         it "find multiple children" do
            parent = Arquillian::Scanner::Context.new :root

            child_between = parent.new_child :child_between
            child_between.new_child :child
            child_between.new_child :child
            
            expect(parent.find_children(:child).size).to eql 2  
         end

      end

      describe :find_parent do
         subject(:context) do
            parent = Arquillian::Scanner::Context.new :root
            parent[:key] = :test
            child = parent.new_child :child
            child2 = child.new_child :child2

            child2
         end

         it { is_expected.to have_parent :root }
         it { expect(context.find_parent(:root).children.size).to eql 1 }
         it { expect(context.requires_parent :root, :key).to eql :test }
         it { expect{context.requires_parent :root, :missing}.to raise_error("No required missing found in context root") }
         it { expect{context.requires_parent :missing, :key}.to raise_error("No required context missing found") }
      end

   end

end

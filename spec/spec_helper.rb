require 'rubygems'
require 'rspec'


RSpec::Matchers.define :have_child do |*args|
   match do |context|
      context.find_children(*args)
   end

   description do
      "have child context #{args.join(', ')}"
   end

   failure_message do |context|
      "expected to be able to find child #{args.join(', ')} in context #{context.name}"
   end

   failure_message_when_negated do |context|
      "expected not to be able to find child #{args.join(', ')} in context #{context.name}"
   end
end

RSpec::Matchers.define :have_key do |key, matcher|
   match do |context|
      c = context[key]
      matcher.matches? c
   end

   failure_message do |context|
      "expected to be able to find key #{key} in context #{context.name}"
   end

   failure_message_when_negated do |context|
      "expected not to be able to find key #{key} in context #{context.name}"
   end
end

RSpec::Matchers.define :have_parent do |*args|
   match do |context|
      context.find_parent(*args)
   end

   description do
      "have parent context #{args.join(', ')}"
   end

   failure_message do |context|
      "expected to be able to find parent #{args} from context #{context.name}"
   end

   failure_message_when_negated do |context|
      "expected not to be able to find parent #{args} from context #{context.name}"
   end
end

RSpec::Matchers.define :require_parent do |*args|
   match do |context|
      context.requires_parent(*args)
   end

   failure_message do |context|
      "expected to be able to find parent #{args} from context #{context.name}"
   end

   failure_message_when_negated do |context|
      "expected not to be able to find parent #{args} from context #{context.name}"
   end
end

class RSpec::Core::ExampleGroup

   def self.process &block
      before :all do
         @context = instance_eval &block
      end

      subject(:context) { @context }
   end

   def self.in_context child, &block
     
      describe "context #{child}" do
         
         subject(child) do 
            child_context = context.find_children child
            raise "Child context #{child} not found" if child_context.nil? or child_context.size == 0
            child_context.first
         end

         instance_eval &block
      end
   end

end
module Arquillian

   module Scanner

      class Context

         attr_reader :name
         attr_reader :parent
         attr_reader :children

         def initialize(name = "root", parent = nil)
            @name = name
            @children = []
            @content = {}
            @transitive = {}

            @parent = parent
            @parent.child self unless parent.nil?
         end

         def new_child(name)
            Context.new name, self
         end

         def transitive(key, value)
            @transitive[key] = value
         end

         def clear_transitive!
            #puts "clear transitive #{@name}"
            @transitive.clear
            @children.each {|c| c.clear_transitive!}
         end

         def clear_transitive_children!
            @children.each {|c| c.clear_transitive!}
         end

         def [](key)
            #puts "look up #{key} exists in #{@transitive.has_key? key}"
            @content[key] || @transitive[key]
         end

         def []=(key, value)
            @content[key] = value
         end

         def empty?
            @content.empty?
         end

         def find_parent(context_name, key=nil)
            context = locate_named_parent_context context_name
            return context[key] unless key.nil? or context.nil?
            return context if key.nil?
         end

         def find_children(context_name)
            locate_named_child_context context_name
         end

         def requires_parent(context_name, key)
            context = find_parent context_name
            raise "No required context #{context_name} found" if context.nil?
            val = context[key]
            raise "No required #{key} found in context #{context_name}" if val.nil?
            val
         end

         def to_s
            "#{@name}[parent=#{parent.name unless parent.nil?}, children=#{children.size}]: #{@content.to_s}"
         end
         
         protected

         def child(child)
            @children << child
         end

         def locate_named_parent_context(name)
            return self if @name.eql? name
            return parent.locate_named_parent_context(name) unless parent.nil?
            nil
         end

         def locate_named_child_context(name)
            val = []
            @children.each do |child|
               if name.eql? child.name
                  val << child 
               else
                  val.push *(child.locate_named_child_context name)
               end
            end
            val
         end

      end


      class Processor

         attr_reader :name

         def initialize(name, &block)
            #puts "Initialize #{name} #{block}"
            @name = name
            @children = []
            self.instance_eval &block if block
         end

         def child(processor)
            #puts "Child #{processor.name} of #{@name}"
            @children << processor
         end

         def process(context = Context.new(:root))
            #puts "process #{self.class}"
            begin
               work(context)
            ensure
               #puts "Clear #{context.name} in #{self.class}"
               context.clear_transitive_children!
            end
            context
         end

         def process_children(child_context)
            #puts "process children #{child_context.name} #{@children.size}"
            @children.each_with_index do |processor, index|
               #puts "process child #{processor.class} #{index}"
               processor.process child_context
            end
         end

         def work(parent_context)
         end

      end


   end
end
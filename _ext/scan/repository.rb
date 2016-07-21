require 'yaml'

module Awestruct
   module Repository
      class Collector

         attr_reader :collectors

         def initialize(collectors = [], &block)
            @collectors = collectors
             self.instance_eval &block if block
         end

         def collector(collector)
            @collectors << collector
         end

         def collect
            collectors.map {|c|
               c.send(:repositories) if c.respond_to? :repositories}.flatten
         end

         def exec(site)
            site.repositories = collect
         end
      end

      class FileCollector

         def initialize(file_name)
            @file_name = file_name
         end

         def repositories
            YAML.load(IO.read @file_name)
         end
      end


      class Processor

         def initialize(processors = [], &block)
            @processors = processors
            self.instance_eval &block if block
         end

         def processor(processor)
            @processors << processor
         end

         def process()
            @processors.each do |processor|
               processor.process
            end
         end

         def exec(site)
            site.data = process site.repositories
         end
      end

   end
end
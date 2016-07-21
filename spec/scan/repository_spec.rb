require_relative '../../_ext/scan/repository.rb'

describe Awestruct::Repository::Collector do

   class CollectA
      def repositories
         return ['A', 'B']
      end
   end

   class CollectB
      def repositories
         return ['C', 'D']
      end
   end

   describe "Basic collector features" do

      it "Should be able to register multiple collectors" do

         collector = ::Awestruct::Repository::Collector.new [CollectA.new, CollectB.new]

         expect(collector.collectors.size).to eq(2)
      end

      it "Should be able to register in initialization block" do

         collector = ::Awestruct::Repository::Collector.new do
            collector CollectA.new
            collector CollectB.new
         end

         expect(collector.collectors.size).to eq(2)
      end

      it "Should be able to accumulate all collectors" do

         collector = ::Awestruct::Repository::Collector.new [CollectA.new, CollectB.new]
         repositories = collector.collect

         expect(repositories.size).to eq(4)
         expect(repositories).to include('A', 'B', 'C', 'D')
      end
   end

   describe Awestruct::Repository::FileCollector do

      it "Should be able to load repositories from file" do

         collector = ::Awestruct::Repository::FileCollector.new File.join File.dirname(__FILE__), "file_collector_spec.yml"
         repositories = collector.repositories

         expect(repositories.size).to eq(2)
      end
   end
end
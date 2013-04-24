require 'spec_helper.rb'

require 'dsort.rb'

describe DSort do
  describe "#dsort" do
    context "with dependency pairs" do
      it "should do a dependency sort" do
        pairs = [[:a, :b], [:b, :c], [:c, :c]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept duplicate keys" do
        pairs = [[:a, :b], [:b, :c], [:a, :c], [:c, :c]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept 'leaf' dependencies" do
        pairs = [[:a, :b], [:b, :c]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
    end
    context "with object to array of dependencies pairs" do
      it "should do a dependency sort" do
        pairs = [[:a, [:b, :c]], [:b, [:c]], [:c, [:c]]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept duplicate keys" do
        pairs = [[:a, [:b]], [:b, [:c]], [:a, [:c]], [:c, [:c]]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept 'leaf' dependencies" do
        pairs = [[:a, [:b, :c]], [:b, [:c]]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
    end
    context "with objects and a block" do
      it "should do a dependency sort" do
        objs = [Integer, Numeric, Float, Object, BasicObject]
        DSort.dsort(objs) { |obj| [obj.superclass].compact }.should == 
            [BasicObject, Object, Numeric, Integer, Float]
      end
      it "should accept 'leaf' dependencies" do
        objs = [Integer, Numeric, Float, Object, BasicObject]
        DSort.dsort(objs) { |obj| [obj.superclass] }.should == 
            [nil, BasicObject, Object, Numeric, Integer, Float]
      end
    end
  end
  describe "#tsort" do
    it "should be equivalent to DSort::dsort(...).reverse" do
      pairs = [[:a, :b], [:b, :c]]
      DSort.tsort(pairs).should == [:c, :b, :a].reverse
    end
  end
end


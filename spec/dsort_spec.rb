require 'spec_helper.rb'

require 'dsort.rb'

# Build a hierarchy of dependencies
$HASH_DEPS = {
  :a => [:b, :c],
  :b => [:c, :d],
  :c => :d
}

$BLOCK_DATA = {
  :a => [:b, :c],
  :b => [:c, :d],
  :c => [:d]
}

describe DSort::Cyclic do
  describe "#cycles" do
    it "should be a list of cycles" do
      pairs = [[:a, :b], [:b, :a]]
      begin
        DSort.dsort(pairs).should == 1
      rescue DSort::Cyclic => e
        e.cycles.size.should == 1
        e.cycles[0].sort.should == [:a, :b]
      end
    end
    it "should be sorted from shortest to longest cycle" do
      pairs = [[:a, :b], [:b, :a], [:A, :B], [:B, :C], [:C, :A]]
      begin
        DSort.dsort(pairs).should == 1
      rescue DSort::Cyclic => e
        e.cycles.size.should == 2
        e.cycles[0].sort.should == [:a, :b]
        e.cycles[1].sort.should == [:A, :B, :C]
      end
    end
  end
end

describe DSort do
  describe "#dsort" do
    context "with an array argument" do
      it "should do a dependency sort" do
        pairs = [[:a, :b], [:b, :c]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept self-dependencies" do
        pairs = [[:a, :b], [:b, :c], [:c, :c]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept duplicate keys" do
        pairs = [[:a, :b], [:b, :c], [:a, :c]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept duplicate dependencies" do
        pairs = [[:a, :b], [:a, :b], [:b, :c], [:a, :c]]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept lists of dependencies" do
        pairs = [ [:a, [:b, :c]], [:b, [:c]] ]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept empty lists of dependencies" do
        pairs = [ [:a, [:b, :c]], [:b, [:c]], [:c, []] ]
        DSort.dsort(pairs).should == [:c, :b, :a]
      end
      it "should accept arrays as values" do
        a, b, c = [:a], [:b], [:c]
        pairs = [ [a, [b, c]], [b, [c]] ]
        DSort.dsort(pairs).should == [c, b, a]
      end
    end
    context "with a hash argument" do
      it "should do a dependency sort" do
        DSort.dsort($HASH_DEPS).should == [:d, :c, :b, :a]
      end
    end
    context "with objects and a block" do
      it "should do a dependency sort" do
        objs = [Integer, Numeric, Float, Object, BasicObject]
        DSort.dsort(objs) { |obj| [obj.superclass].compact }.should == 
            [BasicObject, Object, Numeric, Integer, Float]
      end
      it "should collect dependencies recursively" do
        s = DSort.dsort(:a) { |obj| $BLOCK_DATA[obj] || [] }
        s.should == [:d, :c, :b, :a]
      end
    end
    context "with circular dependencies" do
      context "should raise DSort::Cyclic" do
        it "when given an array argument" do
          lambda {
            pairs = [[:a, :b], [:b, :a]]
            DSort.dsort(pairs).should == 1
          }.should raise_error(DSort::Cyclic)
        end
      
        it "when given a block argument" do
          l = lambda { |node| [node == :a ? :b : :a] }
          expect {
            DSort.dsort(:a, &l)
          }.to raise_error(DSort::Cyclic)
        end
      end
    end
  end
  describe "#tsort" do
    context "with an array argument pairs" do
      it "should be equivalent to DSort::dsort(...).reverse" do
        a, b, c = [:a], [:b], [:c]
        test_pairs = [ # From the dsort tests above
          [[:a, :b], [:b, :c]],
          [[:a, :b], [:b, :c], [:c, :c]],
          [[:a, :b], [:b, :c], [:a, :c]],
          [[:a, :b], [:a, :b], [:b, :c], [:a, :c]],
          [ [:a, [:b, :c]], [:b, [:c]] ],
          [ [:a, [:b, :c]], [:b, [:c]], [:c, []] ],
          [ [a, [b, c]], [b, [c]] ]
        ]
        test_pairs.each { |pairs|
          DSort.tsort(pairs).should == DSort.dsort(pairs).reverse
        }
      end
    end
    context "with a hash argument" do
      it "should be equivalent to DSort::dsort(...).reverse" do
        pairs = { :a => :b, :b => :c }
        DSort.tsort(pairs).should == DSort.dsort(pairs).reverse
      end
    end
    context "with objects and a block" do
      it "should be equivalent to DSort::dsort(...).reverse" do
        objs = [Integer, Numeric, Float, Object, BasicObject]
        DSort.tsort(objs) { |obj| [obj.superclass].compact }.should == 
            DSort.dsort(objs) { |obj| [obj.superclass].compact }.reverse

        s = DSort.tsort(:a) { |obj| $BLOCK_DATA [obj] || [] }
        s.should == [:a, :b, :c, :d]
      end
    end
    context "with circular dependencies" do
      it "should raise DSort::Cyclic" do
       lambda {
          pairs = [[:a, :b], [:b, :a]]
          DSort.tsort(pairs).should == 1
       }.should raise_error(DSort::Cyclic)
      end
    end
  end
end


require "dsort/version"

require 'tsort'

module DSort
  # dsort sort its input in "dependency" order: The input can be though of
  # depends-on relations between objects and the output as sorted in the order
  # needed to safisfy those depends-on relations. Three formats can be used:
  #
  # dsort [[:a, :b], [:b, :c]]
  #     array of pairs where the first element comes before the second
  # dsort [[:a, [:b, :c, :d]], [:b, [:c, :d]]
  #     array of pairs where the first element comes before all the elements in
  #     the second array
  # dsort([obj1, obj2, obj3]) { |obj| obj.followers }
  #     array of objects that are given to the block. The block should return a
  #     list of elements that comes after the given object
  #
  # An example: If we have that dsort depends on ruby and rspec, ruby depends
  # on C to compile, and rspec depends on ruby, then in what order should we
  # build them ? Using dsort we could do
  #
  #   require 'dsort'
  #   p dsort [[:dsort, :ruby], [:dsort, :rspec], [:ruby, :C], [:rspec, :ruby]]
  #       => [:C, :ruby, :rspec, :dsort]
  #
  def dsort(a, &block) Private::DSortObject.new(a, &block).tsort end

  # tsort sort its input in topological order: The input can be thought of as
  # comes-before relations between objects and the output will be in
  # first-to-last order. This definition corresponds to the mathemacial
  # defitionnn of topological sort. See
  # http://en.wikipedia.org/wiki/Topological_sorting. Three formats can be
  # used:
  #
  # tsort [[:a, :b], [:b, :c]]
  #     array of pairs where the first element comes before the second
  # tsort [[:a, [:b, :c, :d]], [:b, [:c, :d]]
  #     array of pairs where the first element comes before all the elements in
  #     the second array
  # tsort([obj1, obj2, obj3]) { |obj| obj.followers }
  #     array of objects that are given to the block. The block should return a
  #     list of elements that comes after the given object
  #     
  #   
  #
  #
  def tsort(a, &block) dsort(a, &block).reverse end

  module_function :dsort, :tsort

  module Private
    class DSortObject
      include TSort

      attr_reader :deps

      # Create @deps hash from object to list of dependencies
      def initialize(a, &block)
        @deps = {}
        
        # Array of objects
        if block_given?
          a.each { |obj| @deps[obj] = block.call(obj) }

        # Array of pairs
        elsif !a.empty? && a.first.is_a?(Array) && a.first.last.is_a?(Array)
          a.each { |k, ds| (@deps[k] ||= []).concat(ds) }

        # Array of object and object dependencies pairs
        else
          a.each { |e| (@deps[e.first] ||= []) << e.last }
        end

        # Make sure all dependent objects are also represented as depending
        # objects
        @deps.values.flatten.each { |obj| @deps[obj] = [] if !@deps.key?(obj) }
      end

      def tsort_each_node(&block) @deps.each_key(&block) end
      def tsort_each_child(node, &block) @deps[node].each(&block) end
    end
  end
end


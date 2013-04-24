require "dsort/version"

require 'tsort'

module DSort
  # dsort make a dependency sort on a partially ordered set so that objects
  # depending on other objects comes last in the sort order
  #
  # dsort can be initialized with an array of dependencies or an array of
  # objects. If an array of objects is used then a block should also be
  # supplied to extract the dependency information from the objects. The block
  # should take one object argument and return an array of objects
  #
  # Examples
  #   dsort [[:a, :b], [:a, :c], [:b, :c]]      # keys can be repeated
  #   dsort [[:a, [:b, :c, :d]], [:b, [:c, :d]]
  #   dsort([obj1, obj2, obj3]) { |obj| obj.dependencies }
  #
  def dsort(a, &block) Private::DSortObject.new(a, &block).tsort end
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


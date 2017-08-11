require "dsort/version"

require 'tsort'

module DSort
  # dsort sort its input in "dependency" order: The input can be though of
  # depends-on relations between objects and the output as sorted in the order
  # needed to safisfy those depends-on relations
  #
  # Input can be an array of relations where each relation is a pair (array) of
  # an element and the element(s) it depends on: [[:a, :b], [:a, :c]] or [[:a,
  # [:b, :c]]]. Note that if your elements are arrays then you need to put the
  # second element in an array even if there's only one like this [array1,
  # [array2]]. If a block is given, the arguments should be an array of objects
  # and the block return an array of objects it depends on
  #
  # Example: If we have that dsort depends on ruby and rspec, ruby depends
  # on C to compile, and rspec depends on ruby, then in what order should we
  # build them ? Using dsort we could do
  #
  #   require 'dsort'
  #   p dsort [[:dsort, :ruby, :rspec]], [:ruby, :C], [:rspec, :ruby]]
  #       => [:C, :ruby, :rspec, :dsort]
  #
  def dsort(a, &block) DSortPrivate::DSortObject.new(a, &block).tsort end

  # tsort sort its input in topological order: The input can be thought of as
  # comes-before relations between objects and the output will be in
  # first-to-last order. This definition corresponds to the mathemacial
  # defitionnn of topological sort. See
  # http://en.wikipedia.org/wiki/Topological_sorting
  #
  # Input can be an array of relations where each relation is a pair (array) of
  # an element and the element(s) it precedes: [[:a, :b], [:a, :c]] or [[:a,
  # [:b, :c]]]. Note that if your elements are arrays then you need to put the
  # second argument in an array even if there's only one like this [array1,
  # [array2]]. If a block is given, the arguments should be an array of objects
  # and the block return an array of succeeding objects
  #
  def tsort(a, &block) dsort(a, &block).reverse end

  module_function :dsort, :tsort

  module DSortPrivate
    class DSortObject
      include TSort

      # Hash from element to array of dependencies
      attr_reader :deps

      # Create @deps hash from object to list of dependencies
      def initialize(a, &block)
        @deps = {}
        if block_given?
          a.each { |obj| @deps[obj] = block.call(obj) }
        else
          a.each { |obj, deps| 
            (@deps[obj] ||= []).concat(deps.is_a?(Array) ? deps : [deps])
          }
        end

        # Make sure all dependent objects are also represented as depending
        # objects: If we're given [[:a, :b]] we want the @deps hash to include
        # both :a and :b as keys
        @deps.values.each { |deps|
          (deps.is_a?(Array) ? deps : [deps]).each { |d|
            @deps[d] = [] if !@deps.key?(d)
          }
        }
      end

      # TSort virtual methods
      def tsort_each_node(&block) @deps.each_key(&block) end
      def tsort_each_child(node, &block) @deps[node].each(&block) end
    end
  end
end


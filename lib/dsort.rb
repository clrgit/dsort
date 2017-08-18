require "dsort/version"

require 'tsort'

module DSort
  # Thrown if a cyclic dependency is detected
  Cyclic = TSort::Cyclic

  # dsort sorts its input in "dependency" order: The input can be thought of
  # depends-on relations between objects and the output as sorted in the order
  # needed to safisfy those dependencies so that no object comes before an
  # object it depends on
  #
  # dsort can take an array or a hash argument, or be supplied with a block
  #
  # The Array argument should consist of pairs (two-element Arrays) with the
  # first element being the depending object and the second an object or an
  # array of objects it depends on: For example [:a, :b] means that :a depends
  # on :b, and [:b, [:c, :d]] that :b depends on both :c and :d
  #
  # The Hash argument should be a hash from depending object to an object or
  # array of objects it depends on. If h is a Hash then dsort(h) is equivalent
  # to dsort(h.to_a)
  #
  # Note that if the elements are arrays themselves, then you should use the
  # array form to list the dependencies even if there is only one dependency.
  # Ie. use [:a, [:b]] or {:a => [:b] } instead of [:a, :b] or {:a => :b}
  #
  # If dsort is given a block, the block is given an element as argument and
  # should return an (possibly empty) array of the objects the argument depends
  # on. The argument to dsort should be an element or an array of elements to
  # be given to the block. Note that if the elements are arrays themselves,
  # then the arguments to dsort should use the array form even if there is only
  # one element. Ie.  Use dsort([:a]) instead of dsort(:a)
  #
  # dsort raise a DSort::Cyclic exception if a cycle detected (DSort::Cyclic is
  # inherited from TSort::Cyclic)
  #
  # Example: If we have that dsort depends on ruby and rspec, ruby depends
  # on C to compile, and rspec depends on ruby, then in what order should we
  # build them ? Using dsort we could do
  #
  #   p dsort [[:dsort, [:ruby, :rspec]]], [:ruby, :C], [:rspec, :ruby]]
  #       => [:C, :ruby, :rspec, :dsort]
  #
  # Using a hash
  #
  #   h = {
  #     :dsort => [:ruby, :rspec],
  #     :ruby => [:C],
  #     :rspec => [:ruby]
  #   }
  #   p dsort(h) # Same as dsort(h.to_a)
  #       => [:C, :ruby, :rspec, :dsort]
  #
  # or using a block
  #
  #   p dsort(:dsort) { |e| h[e] }
  #       => [:C, :ruby, :rspec, :dsort]
  #
  def dsort(a, &block) DSortPrivate::DSortObject.new(a, &block).tsort end

  # tsort sort its input in topological order: The input can be thought of as
  # comes-before relations between objects and the output will be in
  # first-to-last order. This definition corresponds to the mathemacial
  # defitionnn of topological sort. See
  # http://en.wikipedia.org/wiki/Topological_sorting
  #
  # Arguments are the same as for dsort. tsort is equivalent to
  # dsort(...).reverse
  #
  # tsort raise a DSort::Cyclic exception if a cycle is detected (DSort::Cyclic
  # is an alias for TSort::Cyclic)
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
          a = [a] if !a.is_a?(Array)
          a.each { |elem| find_dependencies(elem, &block) }
        else
          a = a.to_a if a.is_a?(Hash)
          a.each { |obj, deps| 
            (@deps[obj] ||= []).concat(deps.is_a?(Array) ? deps : [deps])
          }
        end

        # Make sure all dependent objects are also represented as depending
        # objects: If we're given [:a, :b] we want the @deps hash to include
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

    private
      def find_dependencies(a, &block)
        block.call(a).each { |d|
          (@deps[a] ||= []) << d
          find_dependencies(d, &block)
        }
      end
    end
  end
end











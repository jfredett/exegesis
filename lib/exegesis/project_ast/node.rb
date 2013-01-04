# Represents a single node in the AST of a project structure
module AST
  class Visitor
    def before_visit!(node)
      #intentionally blank - implement in subclass
    end

    def after_visit!(node)
      #intentionally blank - implement in subclass
    end

    def call(node)
      return send(node.method_name, node) if respond_to?(node.method_name)
      unknown(node)
    end
  end

  module Node
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
      base.send(:include, Enumerable)
    end

    class ObjectSet < Array
      def visit(visitor)
        each do |c|
          c.visit(visitor)
        end
      end
    end

    module InstanceMethods
      #this is terrible
      def method_name
          #get the classname
        self.class.name.
          #remove the module
          to_s.split('::').last.
          #convert FooBar -> _Foo_Bar
          gsub(/[A-Z]/, '_\&').
          #drop the leading _
          gsub(/^_/, '').
          #downcase everything to get foo_bar
          downcase.to_sym
      end

      def visit(visitor)
        visitor.before_visit!(self)
        visitor.call(self)

        each do |c|
          c.visit(visitor)
        end

        visitor.after_visit!(self)
        nil
      end

      def run
      end

      def each(&block)
        children.values.each(&block)
      end

      def children
        @children ||= {}
      end

      def name
        @name || self.class.name
      end

      def initialize(name = nil, opts = {}, &block)
        @name = name
        @opts = opts
        instance_eval &block if block_given?
      end

      def terminal?
        self.class.terminal?
      end
    end

    module ClassMethods
      def nonterminal(type)
        raise "NonterminalInTerminalError" if terminal? && binding.pry
        define_method(type_to_method_name(type)) do |name=nil, opts={}, &block|
          if children.has_key?(type) and children[type]
            children[type].run(&block)
          else
            children[type] = type.new(name, opts={}, &block)
          end
          children[type]
        end
      end

      def terminal(type)
        #should only allow one.
        raise "InvalidNodeTypeError" unless type.terminal? || binding.pry
        define_method(type_to_method_name(type)) do |name=nil, opts={}, &block|
          raise "TerminalAlreadySetError" if children.has_key?(type)
          children[type] = type.new(name, opts, &block)
        end
      end
      def terminal!
        define_singleton_method(:terminal?) { true }
      end
      def terminal?; false end

      def multiple(type)
        #should store an entry in #children that is a list of all the instances
        #it sees of this type. eg, `file 'x'; file 'y' #=> children[File] = [File<@name=x>, File<@name=y>]
        raise "InvalidNodeTypeError" unless type.terminal? || binding.pry
        define_method(type_to_method_name(type)) do |name, opts={}, &block|
          children[type] ||= ObjectSet.new
          children[type] << type.new(name, opts, &block)
        end
      end

      private

      def type_to_method_name(type)
        if type.respond_to?(:name)
          type.name
        else
          type.to_s
        end.split('::').last.downcase
      end
    end
  end

  class SourceFile
    include Node
    terminal!

    def self.name
      "File"
    end
  end

  class Src
    include Node
    terminal!
  end

  class Obj
    include Node
    terminal!
  end

  class Bin
    include Node
    terminal!
  end

  class Test
    include Node
    terminal!
  end

  class Deps
    include Node
    terminal!

    def self.name
      'Dependencies'
    end
  end

  class License
    include Node
    terminal!
  end

  class Directory
    include Node

    nonterminal Directory
    multiple SourceFile
  end

  class Binary
    include Node
    terminal!

    terminal Deps
  end

  class Lib
    include Node
    terminal!

    terminal Deps
  end

  class Compiler
    include Node
    terminal!
  end

  class Package
    include Node
    terminal!
  end

  class Structure
    include Node

    terminal Src
    terminal Obj
    terminal Test
    terminal Bin

    multiple SourceFile

    terminal License

    nonterminal Directory

  end

  class Products
    include Node

    nonterminal Binary
    nonterminal Lib
  end

  class Dependencies
    include Node

    multiple Compiler
    multiple Package
  end

  class Project
    include Node

    nonterminal Structure
    nonterminal Products
    nonterminal Dependencies
  end

  def self.project(name, opts={}, &block)
    Project.new(name, opts, &block)
  end
end

class Project
  def initialize(project_ast)
    @project_ast = project_ast
  end
end

module Dotify
  class Collection

    include Enumerable

    attr_accessor :dots
    module Filter
      extend self
      def home
        result = dots(Config.home('.*'))
        filter_ignore_files!(result, :dotfiles)
      end

      def dotify
        result = dots(Config.path('.*'))
        filter_ignore_files!(result, :dotify)
      end

      def dots(glob)
        filter_dot_directories! Dir[glob].map{ |file| Dot.new(file) }
      end

      def filter_dot_directories!(dots)
        [*dots].delete_if { |f| %w[. ..].include? f.filename }
      end

      def filter_ignore_files!(dots, ignore)
        ignoring = Config.ignore(ignore)
        [*dots].delete_if { |f| ignoring.include?(f.filename) }
      end

      def filenames(dots)
        dots.map(&:filename)
      end
    end

    def self.home
      Collection.new(Filter.home)
    end

    def self.dotify
      Collection.new(Filter.dotify)
    end

    # Pulls an array of Dots from the home
    # directory.
    def initialize(dots_from_filter)
      @dots ||= dots_from_filter
    end

    # Defined each method for Enumerable
    def each(&block)
      dots.each(&block)
    end

    # Linked files are those files which have a
    # symbolic link pointing to the Dotify file.
    def linked
      select(&:linked?)
    end

    # Unlinked files are, of course, the opposite
    # of linked files. These are Dotify files which
    # Have no home dir files that are linked to them.
    def unlinked
      reject(&:linked?)
    end

    def to_s
      dots.to_s
    end

    def inspect
      dots.map(&:inspect)
    end

  end
end

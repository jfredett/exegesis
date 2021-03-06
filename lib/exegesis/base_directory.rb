# class BaseDirectory IS_A Directory
#  HAS_A Root
#  HAS_MANY Directories
#  HAS_MANY SourceFiles (files)
#
# Responsibilities:
#  Expose properties of the root directory, Spawn the initial set of
#  directories which will recursively find all the files in the project
#
#  The class will also wrap some of the SourceFile macros, like #join and
#  #expand_path and stuff. Think along the lines of Rails.root and the like.
#
# Collaborators:
#  [Directory]
#  [SourceFile]
module Exegesis
  class BaseDirectory < Directory
    # @param root [String] the root path of the project
    # @param searcher [FileSearcher] an object used to search for files in a given
    #    directory
    def initialize(root, searcher = FileSearcher)
      super(nil, root, searcher)
    end

    # The path to the root of the project
    def path
      name
    end
    alias root path
  end
end

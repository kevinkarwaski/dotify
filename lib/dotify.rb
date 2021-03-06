require 'fileutils'

require 'dotify/core_ext/dir'

# Everything else
require 'dotify/config'
require 'dotify/errors'
require 'dotify/version'

# Objects to manage dotfiles
require 'dotify/dot'
require 'dotify/collection'

# CLI
require 'dotify/cli/utilities'
require 'dotify/cli/listing'
require 'dotify/cli/repo'
require 'dotify/cli'


module Dotify

  def self.installed?
    Config.installed?
  end

  def self.version
    @version ||= Version.build.level
  end

  def self.collection
    @collection ||= Collection.home
  end
end

# The most pragmatic approach to ease the usage of our rake helper library is
# to require this file which itself requires all other files.
require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)

$LOAD_PATH.unshift '.'
$LOAD_PATH.unshift File.dirname(__FILE__)

require "require_ext"

require "log"
require "platform"
require "template_task"
require "clean"
require "file_utils_ext"
require "download_task"
require "git_task"
require "zip_task"

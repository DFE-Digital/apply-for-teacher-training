require 'pagy/extras/metadata'
require 'pagy/extras/headers'
require 'pagy/extras/array'
require 'pagy/extras/overflow'

# `empty_page` is default for the UI
# exception should be used in all API contexts
Pagy::DEFAULT[:overflow] = :empty_page

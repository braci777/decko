require_dependency "card/view/visibility"
require_dependency "card/view/cache"
require_dependency "card/view/stub"
require_dependency "card/view/options"

class Card
  class View
    # Card::View handles view rendering and caching.

    include Visibility
    include Cache
    include Stub
    include Options
    extend Cache::ClassMethods

    attr_reader :format, :parent, :card
    attr_accessor :unsupported_view

    # @return [Symbol]
    def self.canonicalize view
      return if view.blank? # error?
      view.to_viewname.key.to_sym
    end

    # @param format [Card::Format]
    # @param view [Symbol]
    # @param raw_options [Hash]
    # @param parent [Card::View] (optional)
    def initialize format, view, raw_options={}, parent=nil
      @format = format
      @raw_view = view
      @raw_options = raw_options
      @parent = parent

      @card = @format.card
      normalize_options
    end

    # handle rendering, including optional visibility, permissions, and caching
    # @return [rendered view or a stub]
    def process
      process_live_options
      process_visibility_options
      return if optional? && hide?(requested_view)
      fetch { yield ok_view, foreign_live_options }
    end

    # the view to "attempt".  Typically the same as @raw_view, but @raw_view can
    # be overridden, eg for the main view (top view of the main card on a page)
    # @return [Symbol] view name
    def requested_view
      @requested_view ||= View.canonicalize live_options[:view]
    end

    # the final view.  can be different from @requested_view when there are
    # issues with permissions, recursions, unknown cards, etc.
    # @return [Symbol] view name
    def ok_view
      @ok_view ||= format.ok_view requested_view,
                                  normalized_options[:skip_perms]
    end

    # @return [Card::View]
    def root
      @root = parent ? parent.root : self
    end

    # neither view nor format has a parent
    def deep_root?
      !parent && !format.parent
    end

  end
end

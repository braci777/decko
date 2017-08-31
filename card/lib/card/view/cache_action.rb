class Card
  class View
    module CacheAction
      # determine action to be used in #fetch

      # course of action based on config/status/options
      # @return [Symbol] :yield, :cache_yield, or
      def cache_action
        action = send "#{cache_status}_cache_action"
        log_cache_action action
        action
      end

      def log_cache_action action
        return false # TODO: make configurable
        puts "FETCH_VIEW (#{card.name}##{requested_view})" \
             "cache_action = #{action}"
      end

      # @return [Symbol] :off, :active, or :ready
      def cache_status
        case
        when cache_off?    then :off    # view caching is turned off, system-wide
        when cache_active? then :active # another view cache is in progress; this view is inside it
        else                    :free   # no other cache in progress
        end
      end


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # CACHE STATUS: OFF
      # view caching is turned off, system-wide

      # @return [True/False]
      def cache_off?
        !Card.config.view_cache
      end

      # always skip all the magic
      def off_cache_action
        :yield
      end


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # CACHE STATUS: FREE
      # caching is on; no other cache in progress

      def free_cache_action
        free_cache_ok? ? :cache_yield : :yield
      end

      # @return [True/False]
      def free_cache_ok?
        cache_setting != :never &&
          foreign_live_options.empty? &&
          clean_enough_to_cache?
        # note: foreign options are a problem in the free cache, because
      end

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # CACHE STATUS: ACTIVE
      # another view cache is in progress; this view is inside it

      def active_cache_action
        return :yield if ok_view == :too_deep
        action = active_cache_ok? ? active_cache_setting : :stub
        validate_stub if action == :stub
        action
      end

      # @return [True/False]
      def active_cache_ok?
        return false unless parent && clean_enough_to_cache?
        return true if normalized_options[:skip_perms]
        active_cache_permissible?
      end

      def active_cache_permissible?
        case permission_task
        when :none                  then true
        when parent.permission_task then true
        when Symbol                 then card.anyone_can?(permission_task)
        else                             false
        end
      end

      # task directly associated with the view in its definition via the
      # "perms" directive
      def permission_task
        @permission_task ||= Card::Format.perms[requested_view] || :read
      end

      ACTIVE_CACHE_LEVEL =
        {
          always: :cache_yield, # read/write cache specifically for this view
          standard: :yield,     # render view; it will only be cached within active view
          never: :stub          # render a stub
        }.freeze

      def active_cache_setting
        level = ACTIVE_CACHE_LEVEL[cache_setting]
        level || raise("unknown cache setting: #{cache_setting}")
      end

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # SHARED METHODS

      # Each of the following represents an accepted value for cache
      # directives on view definitions.  eg:
      #   view :myview, cache: :standard do ...
      #
      # * *standard* (default) cache when possible, but avoid double caching
      #   (caching one view while already caching another)
      # * *always* cache whenever possible, even if that means double caching
      # * *never* don't ever cache this view
      #
      # @return [Symbol] :standard, :always, or :never
      def cache_setting
        format.view_cache_setting requested_view
      end


      # altered view requests and altered cards are not cacheable
      # @return [True/False]
      def clean_enough_to_cache?
        requested_view == ok_view &&
          !card.unknown? &&
          !card.db_content_changed?
        # FIXME: might consider other changes as disqualifying, though
        # we should make sure not to disallow caching of virtual cards
      end

    end
  end
end

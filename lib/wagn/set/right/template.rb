module Wagn
  module Set::Right::Template
    include Wagn::Sets

    format :base

    define_view  :core, :right=>'content' do |args|
      with_inclusion_mode :template do
        self._final_core args
      end
    end
    alias_view :core, {:right=>'content'}, {:right=>'default'}

    # this view is technically defined on all cards.  should move soon.
    define_view :template_rule, :tags=>:unknown_ok do |args|
      tname = args[:include_name].gsub /\b_(left|right|whole|self|user|main|\d+|L*R?)\b/, ''
      if tname !~ /^\+/
        "{{#{args[:include]}}}"
      else
        tmpl_set_name = parent.card.cardname.left_name
        set_name = # find the most appropriate set to use as prototype for inclusion
          if tmpl_set_class_name = tmpl_set_name.tag_name and Card[tmpl_set_class_name].codename == 'type'
            "#{tmpl_set_name.left_name}#{args[:include_name]}+#{Card[:type_plus_right].name}"  # *type plus right
          else
            "#{tname.gsub /^\+/,''}+#{Card[:right].name}"                                      # *right
          end
        subrenderer( Card.fetch(set_name) ).render_template_link args
      end

    end
  end
end

module Card::ActiveRecordHelper
  def create_card args
    resolve_name_conflict args
    Card.create! args
  end

  def create_card! args
    create_card args.reverse_merge(rename_if_conflict: :new)
  end

  def update_card name, args
    resolve_name_conflict args
    Card[name].update_attributes! args
  end

  def update_card! args
    update_card args.reverse_merge(rename_if_conflict: :new)
  end

def create_or_update name_or_args, args={}
  	    if name_or_args.is_a?(Hash)
  	      name = name_or_args.delete :name
  	      args = name_or_args
	    else
  	      name = name_or_args
	    end
    else
      create_card args.merge(name: name)
    end
  end

  def create_or_update! name_or_args, args=nil
    if name_or_args.is_a?(Hash)
      name = name_or_args.delete(:name)
      args = name_or_args
    else
      name = name_or_args
      args ||= {}
    end
    create_or_update name, args.reverse_merge(rename_if_conflict: :new)
  end

  def resolve_name_conflict args
    rename = args.delete :rename_if_conflict
    if rename
      args[:name] = Card.uniquify_name args[:name], rename
    end
  end
end
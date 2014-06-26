class CollectionMetadata < ActiveFedora::NtriplesRDFDatastream

  property :member_list, predicate: RDF::DC.relation, class_name: 'ActiveFedora::Rdf::List'

  def members(force_reload = false)
    reset if force_reload
    @target ||= CollectionProxy.new(member_ids)
  end

  def reset
    @target = nil
  end

  def members=(objects)
    reset
    self.member_ids = objects.map(&:pid)
  end

  def member_ids
    member_list.first_or_create
  end

  def member_ids= ids
    ids.each do |id|
      member_ids << id
    end
  end

  def serialize!
    member_ids.resource.persist! #https://github.com/projecthydra/active_fedora/issues/444
    super
  end

end


class CollectionProxy
  def initialize(list)
    @list = list
  end

  def [](index)
    pid = ids[index]
    ActiveFedora::Base.find(pid.to_s)
  end

  def ids
    @list.to_a
  end

  def append(*objects)
    @ids = nil
    objects.each do |o|
      @list << o.pid
    end
  end
  alias_method :<<, :append

  def ==(other)
    to_ary == other
  end

  def to_ary
    ids.map { |pid| ActiveFedora::Base.find(pid.to_s) }
  end

  delegate :each, :size, to: :to_ary

end


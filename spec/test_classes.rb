class ARFaker

  def save
    self.class_variable_get(:@@after_save_callbacks).each do |cb|
      self.send(cb)
    end
  end

  def destroy
    self.class_variable_get(:@@after_destroy_callbacks).each do |cb|
      self.send(cb)
    end
  end

  def self.after_save(*methods)
    unless self.class_variable_defined?(:@@after_save_callbacks)
      self.class_variable_set(:@@after_save_callbacks, [])
    end
    self.class_variable_get(:@@after_save_callbacks).push(*methods)
  end

  def self.after_destroy(*methods)
    unless self.class_variable_defined?(:@@after_destroy_callbacks)
      self.class_variable_set(:@@after_destroy_callbacks, [])
    end

    self.class_variable_get(:@@after_destroy_callbacks).push(*methods)
  end

end


class ModelCacheFake < ARFaker
  include BennyCache::Model

  attr_accessor :id, :other_id

  benny_model_index :other_id, [:x, :y]
  benny_data_index :stuff

end

class RelatedCacheFake < ARFaker
  include BennyCache::Related
  benny_related_index "ModelCacheFake/:model_id/stuff"

  attr_accessor :model_id

end



class BaseSerializer < ActiveModel::Serializer
  def created_at
    object.created_at.to_s
  end
end

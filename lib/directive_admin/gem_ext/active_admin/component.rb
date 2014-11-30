module ActiveAdmin
  class Component < Arbre::Component

    def cake_status_tag(object)
      return unless (status = object["account_status.name"])
      status_tag status, {"Active" => :ok, "Inactive" => :error, "Pending" => :warn}[status]
    end

  end
end

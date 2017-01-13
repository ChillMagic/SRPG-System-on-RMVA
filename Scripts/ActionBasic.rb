#=================================================
# SRPG::ActionBasic
#-------------------------------------------------
# Update : 07/24/2016
#=================================================

module SRPG
  #--------------------------------
  # + Class Data::SelectAction
  #--------------------------------
  module Data
    class SelectAction
      # Attr
      attr_reader :type, :initiator, :target, :data
      # Initialize
      def initialize(type, initiator)
        @type = type
        @initiator = initiator
      end
      # Set
      def set_target(target)
        @target = target
      end
      def set_data(data)
        @data = data
      end
    end
  end
  #--------------------------------
  # + Module ActionBasic
  #--------------------------------
  module ActionBasic
    # Set
    def set_action(type, initiator)
      @data = Data::SelectAction.new(type,initiator)
    end
    def set_target(target)
      @data.set_target(target)
    end
    def set_data(data)
      @data.set_data(data)
    end
    def clear_action
      @data = nil
    end
    # Get
    def get_action
      @data
    end
    def get_type
      get_action ? @data.type : nil
    end
    def get_initiator
      get_action ? @data.initiator : nil
    end
    def get_target
      get_action ? @data.target : nil
    end
    def get_data
      get_action ? @data.data : nil
    end
  end
end

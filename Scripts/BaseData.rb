#=================================================
# SRPG::BaseData
#-------------------------------------------------
# Update : 07/01/2016
#=================================================

module SRPG
  module Data
    #--------------------------------
    # * BaseData
    #--------------------------------
    class BaseData < ReferClass
      def have_nil?
        @data.nil?
      end
    end
  end
end

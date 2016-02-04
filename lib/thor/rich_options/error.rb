# -*-mode: ruby; coding: utf-8 -*-

class Thor
  class ExclusiveArgumentError < InvocationError
  end
  
  class AtLeastOneRequiredArgumentError < InvocationError
  end
end

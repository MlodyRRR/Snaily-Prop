lib.callback.register('snaily-prop:server:removeItem', function(source, itemName)
   return exports.ox_inventory:RemoveItem(source, itemName, 1)
end)

lib.callback.register('snaily-prop:server:addItem', function(source, itemName)
   return exports.ox_inventory:AddItem(source, itemName, 1)
end)

lib.callback.register('snaily-prop:server:checkItem', function(source, itemName)
    return exports.ox_inventory:GetItem(source, itemName, nil, true) > 0
end)

exports('DoesGangExist', function(gang, grade)
    grade = tonumber(grade)
    if gang and grade then
        if ServerGangsData[gang] then
            for k,v in pairs(ServerGangsData[gang].grades) do
                if v.grade == grade then
                    return true
                end
            end
            return false
        end
    end
    return false
end)

exports('GetGangData', function(gang)
    if gang then
        if ServerGangsData[gang] then
            return ServerGangsData[gang]
        end
    end
end)

exports('GetGangGradeNameFromID', function(gang, grade)
    grade = tonumber(grade)
    if gang and grade then
        if ServerGangsData[gang] then
            for k,v in pairs(ServerGangsData[gang].grades) do
                if v.grade == grade then
                    return v.name
                end
            end
        end
    end
end)
Core.MorePlayerFunction = {}
Core.MorePlayerFunction.MGD_GangBuilder = {
    setGang = function(self)
        return function(gang, grade)
            grade = tonumber(grade)

            if exports['mgd_gangbuilder']:DoesGangExist(gang, grade) then
                local gangData = exports['mgd_gangbuilder']:GetGangData(gang)
                local gangGradeName = exports['mgd_gangbuilder']:GetGangGradeNameFromID(gang, grade)

                self.gang.name = gangData.name
                self.gang.label = gangData.label

                self.gang.grade = grade
                self.gang.grade_name = gangGradeName
                self.gang.grade_label = gangData.grades[gangGradeName].label
                self.gang.grade_permissions = gangData.grades[gangGradeName].permissions
                
                self.triggerEvent('mgd_gangbuilder:setGang', self.gang)
                Player(self.source).state:set('gang', self.gang, true)
            else
                print(('(^3mgd_gangbuilder - WARNING^7) Try to setGang an invalid gang (%s) for ID %s !'):format(gang, self.source))
            end
        end
    end,

    getGang = function(self)
        return function()
            return self.gang
        end
    end,

    saveGangData = function(self)
        return function()
            MySQL.update('UPDATE `users` SET `gang` = @gang, `gang_grade` = @gang_grade WHERE `identifier` = @identifier', {
                ['@gang'] = self.gang.name,
                ['@gang_grade'] = self.gang.grade,
                ['@identifier'] = self.identifier
            })
        end
    end,
}
AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Ammo Crate"
ENT.Purpose = "Crate for ammunition."
ENT.Author = "Buckell"

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.Category = "Buckell"

ENT.WorldModel = "models/Items/ammocrate_smg1.mdl"

-- How many "magazines" should you be able to carry/get from the crate.
-- 0 for no limit.
ENT.MaxMagazines = 10

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:SetMoveType(MOVETYPE_VPHYSICS)   
	self:SetSolid(SOLID_VPHYSICS)         
 	
    if SERVER then 
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(CONTINUOUS_USE)
        self.delay = 0
    end

	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(50)
    end
end

if SERVER then
    function ENT:Use(ply)
        if SysTime() < self.delay then return end
    
        self.delay = SysTime() + 0.25
    
        local weapon = ply:GetActiveWeapon()
    
        if not weapon then return end
    
        local ammo_type = weapon:GetPrimaryAmmoType()
        local mag_size = weapon:GetMaxClip1()
    
        if self.MaxMagazines == 0 or ply:GetAmmoCount(ammo_type) + mag_size <= mag_size * 10 then
            ply:GiveAmmo(mag_size, ammo_type)
        elseif ply:GetAmmoCount(ammo_type) < mag_size * 10 then
            ply:SetAmmo(mag_size * 10, ammo_type)
        end
    end
else
    surface.CreateFont("InfiniteCrate.Large", {
        font = "Roboto",
        size = 128,
        weight = 800,
        antialias = true
    })
    
    surface.CreateFont("InfiniteCrate.Small", {
        font = "Roboto",
        size = 72,
        weight = 800,
        antialias = true
    })

    function ENT:Draw()
        self:DrawModel()
    
        local sqr_dist = ply:GetPos():DistToSqr(self:GetPos())
        local alpha = 255
        if sqr_dist > 90000 then alpha = Lerp((sqr_dist - 90000) / 90000, 255, 0) end 
        if alpha == 0 then return end
    
        local oang = self:GetAngles()
        local opos = self:GetPos()
    
        local ang = self:GetAngles()
        local pos = self:GetPos()
    
        ang:RotateAroundAxis(oang:Up(), 90)
        ang:RotateAroundAxis(oang:Right(), -90)
    
        pos = pos + oang:Forward() * 1 + oang:Up() * 30 + oang:Right() * 20
    
        if alpha > 0 then
            cam.Start3D2D(pos, ang, 0.025)
                draw.SimpleText("Ammunition Crate", "InfiniteCrate.Large", 0, 0, Color(255,255,255, alpha))
                draw.DrawText("Press your use key to get ammunition for your weapon.", "InfiniteCrate.Small", 0, 128, Color(255,255,255, alpha))
            cam.End3D2D()
        end
    end
end
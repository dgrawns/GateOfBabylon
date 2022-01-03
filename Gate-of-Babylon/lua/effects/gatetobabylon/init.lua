function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	
	local emitter = ParticleEmitter( Pos )
	
	for i = 1,39 do

		local particle = emitter:Add( "particles/fire_glow", Pos + Vector( math.random(0,0),math.random(0,0),math.random(0,0) ) ) 
		 
		if particle == nil then particle = emitter:Add( "particles/fire_glow", Pos + Vector(   math.random(0,0),math.random(0,0),math.random(0,0) ) ) end
		
		if (particle) then
			particle:SetVelocity(Vector(math.random(0,0),math.random(0,0),math.random(0,0)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(1) 
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(80.722308067898) 
			particle:SetEndSize(20)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(math.random(255,255),math.random(0,255),math.random(0,255),math.random(255,255))
			particle:SetGravity( Vector(0,0,0) ) 
			particle:SetAirResistance(0 )  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end

	emitter:Finish()
		
end
function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end
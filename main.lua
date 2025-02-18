function NEWFUNCTION()

end

function Awake()
    networkedSpinTimer = CreateTickTimerSeconds(1)
    Sword = c.GetModelTransform("Weapon")
    NetworkedSecondaryGroundTimer = CreateTickTimerSeconds(0.2)
    networkedChargeDirection = Vec2(0,0)
    NetworkedSecondarySwingTimer = CreateTickTimerSeconds(1)
    networkedRecoveryLaunchTimer = CreateTickTimerSeconds(1)
    networkedRecoveryAttackTimer = CreateTickTimerSeconds(1)
    networkedUltimateDuration = CreateTickTimerSeconds(1)
    networkedBaseAttackDurationTimer = CreateTickTimerSeconds(1)
    networkedChargeAnimationTimer = CreateTickTimerSeconds(1)
    GroundDelayTime = cf["GroundDelayTime"]
    GroundPoundDistanceScale = cf["GroundPoundDistanceScale"]
    GroundDelayTimer = CreateTickTimerSeconds(GroundDelayTime)
    networkedRecoverForwardLaunch = false
    networkedIsCharging = false
    networkedIsUltimating = false
    networkedStartSpeed=0
    networkedDownVel=0.0
    c.UseGroundDrag = true
    c.CanUltimateAttack = true
    ChargeCooldown = 0
    --STATS
    ChargeCooldownGainRate = cf["ChargeCooldownGainRate"]
    PrimaryMomentum = cf["PrimaryMomentum"]
    SpinSlide = cf["SpinSlide"]
    SlideForce = cf["SlideForce"]
    LungeForce = cf["LungeForce"]
    RecoverWait = cf["RecoverWait"]
    clampedMomentumMultiplier = cf["clampedMomentumMultiplier"]
    secondarySwingLength = cf["secondarySwingLength"]
    Recover1Force = cf["Recover1Force"]
    Recover2Force = cf["Recover2Force"]
    Recover3Force = cf["Recover3Force"]
    ChargeCap=cf["ChargeCap"]
    BaseMomentum=cf["BaseMomentum"]
    BaseAttackDuration = cf["BaseAttackDuration"]
    --NETWORKED
    NetworkedStriking=false
    networkedChargeDirection = Vec3(0,0,0)
    --CHARACTER STUFF
    SavedGroundAcceleration = c.GroundAcceleration
    SavedAirAcceleration = c.AirAcceleration
    SavedJumpForce = c.JumpForce
    SavedDoubleJumpCount = c.DoubleJumpCount
end

function BaseAttack(inputUp, inputHeld, inputDown)
    if (c.CanBaseAttack and c.IsUsingAbility() == false and inputDown) then
        c.IsBaseAttacking = true
        c.CanBaseAttack = false
        c.PlayAnimation("Swing")
        c.PlaySound("Swing", 1, 0, 100)
        c.BaseAttackTimer = CreateTickTimerSeconds(c.BaseAttackCooldown) --the amount for the timers
        networkedBaseAttackDurationTimer = CreateTickTimerSeconds(BaseAttackDuration)
        --BaseAttackTimer = TickTimer.CreateFromSeconds(Runner, BaseAttackCooldown);     
    end 
    if (c.IsBaseAttacking) then
        c.SpawnEffect("slash", 1 ,Sword.TransformPoint(Vec3(0,0,1.3)))
        MomentumControl = MathClamp(c.CharVelocity.magnitude * clampedMomentumMultiplier * BaseMomentum, 0.4, math.huge)
        c.Hitbox(c.CamTransform.TransformPoint(Vec3(0,-0.2,1.5)), LookRotation(c.CamTransform.Forward), Vec3(1,0.5,2.5), c.CamTransform.Forward * c.BaseAttackForce * MomentumControl, c.BaseAttackDamage*MomentumControl, c.BaseAttackInvincibilityTime, c.BaseAttackFlinchTime)
       
    end
    if (networkedBaseAttackDurationTimer.Expired) then
        c.IsBaseAttacking = false;   
    end
    if (c.BaseAttackTimer.Expired) then
       
       c.CanBaseAttack = true
    end
        
end


function Tick()
    if (c.CharVelocity.y > 5) then
        networkedDownVel = 0
    end
    if (networkedDownVel > c.CharVelocity.y) then
        networkedDownVel = c.CharVelocity.y
    end
end

function SpecialAttack(inputUp, inputHeld, inputDown)     
    if (c.CanSpecialAttack and inputDown) then
        networkedStartSpeed=c.CharVelocity.magnitude
        c.CanSpecialAttack = false
        networkedIsCharging = true
        c.UseGroundDrag=false
        ChargeCooldown = 0
        networkedChargeDirection = c.CharTransform.Forward
    end
    if (networkedIsCharging and networkedChargeAnimationTimer.Expired) then
        networkedChargeAnimationTimer = CreateTickTimerSeconds(0.7)
        if not (c.IsAnimationPlaying("Spin") or c.IsAnimationPlaying("HoldLunge") or c.IsAnimationPlaying("Strike") or c.IsAnimationPlaying("Swing") or c.IsAnimationPlaying("HoldRecovery") or c.IsAnimationPlaying("Pound") or c.IsAnimationPlaying("Recovery") or c.IsAnimationPlaying("Lunge")) then
            c.PlayAnimation("Charge")  
        end
        c.PlaySound("Charge", 1, 0, 100)
    end
    if (networkedIsCharging and inputHeld and (c.CharVelocity.magnitude <= networkedStartSpeed+ChargeCap)) then
        c.AddForce(networkedChargeDirection*c.SpecialAttackForce, false) 
        ChargeCooldown = ChargeCooldown + ChargeCooldownGainRate
        if ChargeCooldown>c.SpecialAttackCooldown then
            ChargeCooldown = c.SpecialAttackCooldown
        end
        if (c.IsOnLeftWall or c.IsOnRightWall) then
            networkedStartSpeed= networkedStartSpeed + 1
        end
    end
    if (inputHeld and networkedIsCharging) then
        c.SpawnEffect("KannonDashRightClick", 1 ,c.CharTransform.TransformPoint(Vec3(0,-2,1)),c.CharTransform.Rotation)
    end
    if (inputUp and not c.CanSpecialAttack and networkedIsCharging) then
        c.UseGroundDrag = true
        networkedIsCharging = false
        c.SpecialAttackTimer = CreateTickTimerSeconds(ChargeCooldown)
    end
    if (c.SpecialAttackTimer.Expired and not networkedIsCharging) then
        c.CanSpecialAttack = true
    end
end

function PrimaryAttack(inputUp, inputHeld, inputDown) 
    if (c.CanPrimaryAttack and c.IsUsingAbility() == false and inputDown) then
        c.CanPrimaryAttack = false
        c.IsPrimaryAttacking = true
        c.PlayAnimation("Spin")
        c.PlaySound("Spin", 1, 0, 100)
        c.AddForce(c.CharTransform.Forward* SlideForce)
        networkedStartSpeed = networkedStartSpeed+15
        c.UseGroundDrag=false
        networkedSpinTimer = CreateTickTimerSeconds(SpinSlide)
        c.PrimaryAttackTimer = CreateTickTimerSeconds(c.PrimaryAttackCooldown)
    end
    if (c.IsPrimaryAttacking==true) then
        c.SpawnEffect("slash", 1 ,Sword.TransformPoint(Vec3(0,0,1.3)))
        MomentumControl = MathClamp(c.CharVelocity.magnitude * clampedMomentumMultiplier * PrimaryMomentum, 0.4, math.huge)
        c.Hitbox(c.CharTransform.TransformPoint(Vec3(0,-0.4,0)), LookRotation(c.CharTransform.Forward), Vec3(3.5,1,3.5), c.CharTransform.Forward* c.PrimaryAttackForce * MomentumControl, c.PrimaryAttackDamage*MomentumControl, c.PrimaryAttackInvincibilityTime, c.PrimaryAttackFlinchTime)--Postion, rotation, extents, Hitbox, Damage, Knockback, depth, radius
    end
    if (c.PrimaryAttackTimer.Expired and not c.IsPrimaryAttacking) then
        c.CanPrimaryAttack = true
    end
    if (networkedSpinTimer.Expired and c.IsPrimaryAttacking) then
    
        c.IsPrimaryAttacking = false
        c.UseGroundDrag=true
    end
end

function SecondaryAttack(inputUp, inputHeld, inputDown) 
    if (c.CanSecondaryAttack and c.IsUsingAbility() == false and inputDown)then
        c.CanSecondaryAttack = false
        c.IsSecondaryAttacking = true
        c.CanMove = false
        c.CanJump = false
        c.CanDoubleJump = false
        c.PlayAnimation("Lunge")
        c.PlaySound("DoubleJump", 1, 0, 100)
        networkedStartSpeed = networkedStartSpeed+30
        c.AddForce(c.CharTransform.Forward* LungeForce)
        c.AddForce(c.CharTransform.Up* LungeForce)
        NetworkedSecondaryGroundTimer = CreateTickTimerSeconds(0.2)
    end
    if (c.IsSecondaryAttacking) then
        c.PlayAnimation("HoldLunge")
        c.SpawnEffect("slash", 1 ,Sword.TransformPoint(Vec3(0,0,1.3)))
    end
    if (c.IsSecondaryAttacking and (inputUp or c.IsGrounded)) then
        NetworkedStriking = true
        c.IsSecondaryAttacking = false
        c.PlayAnimation("Strike")
        c.PlaySound("Strike", 1, 0, 100)
        c.CanMove = true
        c.CanJump = true
        c.CanDoubleJump = true
        NetworkedSecondarySwingTimer = CreateTickTimerSeconds(secondarySwingLength)
        c.SecondaryAttackTimer = CreateTickTimerSeconds(c.SecondaryAttackCooldown)
    end
    if (NetworkedSecondarySwingTimer.Expired) then NetworkedStriking = false end
    if (NetworkedStriking)then
        c.SpawnEffect("slash", 1 ,Sword.TransformPoint(Vec3(0,0,1.3)),EulerRotation(Vec3(0,0,0)),c.CharTransform)
        MomentumControl = MathClamp(c.CharVelocity.magnitude * clampedMomentumMultiplier, 0.4, math.huge)
        c.Hitbox(c.CamTransform.TransformPoint(Vec3(0,-0.4,1.5)), c.CamTransform.Rotation*EulerRotation(Vec3(0,0,c.CharTransform.Forward.z+30)), Vec3(3,0.5,3.5), (c.CharTransform.Forward-c.CharTransform.Up) * c.SecondaryAttackForce * MomentumControl, c.SecondaryAttackDamage * MomentumControl, c.SecondaryAttackInvincibilityTime, c.SecondaryAttackFlinchTime)
    end
    if (c.SecondaryAttackTimer.Expired and not c.IsSecondaryAttacking) then
        c.CanSecondaryAttack = true
    end
end

function RecoveryAttack(inputUp, inputHeld, inputDown)
    
    if (c.CanRecoveryAttack and c.IsUsingAbility() == false and inputDown) then
        c.CanRecoveryAttack = false
        c.IsRecoveryAttacking = true
        c.PlaySound("Jump", 1, 0, 100)
        c.PlayAnimation("Recovery")
        c.CharVelocity = Vec3(0, 0, 0)
        c.CanMove = false
        c.CanJump = false
        c.CanDoubleJump = false
        c.RemainingDoubleJumps = 0
        c.AddForce(c.CharTransform.Up* Recover1Force)
        networkedRecoveryLaunchTimer = CreateTickTimerSeconds(RecoverWait)
        GroundDelayTimer = CreateTickTimerSeconds(GroundDelayTime)
        networkedRecoverForwardLaunch = true
    end
    if (networkedRecoveryLaunchTimer.Expired and networkedRecoverForwardLaunch)then
        c.PlaySound("DoubleJump", 1, 0, 100)
        networkedRecoverForwardLaunch = false
        c.CharVelocity = Vec3(0, 0, 0)
        networkedStartSpeed = networkedStartSpeed+10
        c.AddForce(c.CamTransform.Forward*Recover2Force)
        c.AddForce(c.CharTransform.Up*Recover3Force)
    end
    if (c.IsRecoveryAttacking and not networkedRecoverForwardLaunch) then
        c.PlayAnimation("HoldRecovery")
        c.CanMove = false
        c.CanJump = false
        c.CanDoubleJump = false
        if (inputDown) then
            c.CanMove = true
            c.CanJump = true
            c.CanDoubleJump = true
            c.IsRecoveryAttacking = false
            hits=c.Hitbox(c.CamTransform.TransformPoint(Vec3(0,0,4)), EulerRotation(Vec3(0,0,0)), Vec3(2,4,2), Vec3(0,0,0), 0, 0, 0)--Postion, rotation, extents, Hitbox, Damage, Knockback, depth, radius
            c.RecoveryAttackTimer = CreateTickTimerSeconds(c.RecoveryAttackCooldown)
            for k, v in pairs(hits) do
                if ((v.HitCharacter ~= nil) and (v.HitCharacter ~= c)) then
                    MomentumControl = MathClamp(math.abs(networkedDownVel*GroundPoundDistanceScale) * clampedMomentumMultiplier, 0.4, math.huge)
                    c.Hitbox(c.CamTransform.TransformPoint(Vec3(0,0,4)), EulerRotation(Vec3(0,0,0)), Vec3(2,4,2), (c.CharTransform.Up) * -c.RecoveryAttackForce * MomentumControl, c.RecoveryAttackDamage * MomentumControl, c.RecoveryAttackInvincibilityTime, c.RecoveryAttackFlinchTime)
                    c.RecoveryAttackTimer = CreateTickTimerSeconds(0.5)
                    c.AddForce(c.CharTransform.Up*SavedJumpForce)
                end
            end
        end
    end 
    if (not c.IsGrounded and c.IsRecoveryAttacking) then
        GroundDelayTimer = CreateTickTimerSeconds(GroundDelayTime)
    end
    if (c.IsGrounded and c.IsRecoveryAttacking and networkedRecoveryLaunchTimer.Expired and GroundDelayTimer.Expired) then
        c.PlayAnimation("Pound")
        c.CanMove = true
        c.CanJump = true
        c.CanDoubleJump = true
        c.PlaySound("Pound", 1, 0, 100)
        c.SpawnEffect("Boom", 1000, c.CamTransform.TransformPoint(Vec3(0,-1,0)))
        MomentumControl = MathClamp(math.abs(networkedDownVel*GroundPoundDistanceScale) * clampedMomentumMultiplier, 0.4, math.huge)
        c.Hitbox(c.CharTransform.TransformPoint(Vec3(0,-1,0)),EulerRotation(Vec3(0,0,0)), Vec3(10,3,10), (c.CharTransform.Up) * c.RecoveryAttackForce * MomentumControl, c.RecoveryAttackDamage * MomentumControl, c.RecoveryAttackInvincibilityTime, c.RecoveryAttackFlinchTime)
        c.IsRecoveryAttacking = false
        c.RecoveryAttackTimer = CreateTickTimerSeconds(c.RecoveryAttackCooldown)
        c.AddForce(c.CharTransform.Up*SavedJumpForce)
    end
    if (c.RecoveryAttackTimer.Expired and not c.IsRecoveryAttacking) then
        c.CanRecoveryAttack = true
    end
end

function UltimateAttack(inputUp, inputHeld, inputDown)
    if (c.CanUltimateAttack and inputDown) then
        networkedStartSpeed=c.CharVelocity.magnitude
        c.CanUltimateAttack = false
        networkedIsUltimating = true
        c.UseGroundDrag=false
        c.UltimateAttackTimer = CreateTickTimerSeconds(c.UltimateAttackCooldown)
    end
    if (networkedIsUltimating) then
        c.CharVelocity = Vec3(0, 0, 0)
        c.AddForce(c.CamTransform.Forward*c.UltimateAttackForce) 
        c.Hitbox(c.CharTransform.TransformPoint(Vec3(0,0,0)), EulerRotation(Vec3(0, 0, 0)), Vec3(2,2,2), (c.CamTransform.Forward*c.UltimateAttackForce),c.UltimateAttackDamage, 0, 0.1)--Postion, rotation, extents, Hitbox, Damage, Knockback, depth, radius
    end
    if (c.UltimateAttackTimer.Expired and networkedIsUltimating) then
        c.CanUltimateAttack = false
        c.UseGroundDrag=true
        networkedIsUltimating = false
    end
end


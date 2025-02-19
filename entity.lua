function FixedUpdate()
    DebugLog(Entity)
    Entity.GameObject.Transform.Position = Entity.GameObject.Transform.Position + NewVector3(0, 0, 1) * Time.deltaTime
end
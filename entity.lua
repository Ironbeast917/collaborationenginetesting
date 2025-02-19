function FixedUpdate()
    entity.GameObject.Transform.Position = entity.GameObject.Transform.Position + NewVector3(0, 0, 1) * Time.deltaTime
end
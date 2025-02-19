entity = nil

function Start()
    ModelSpawner.SpawnModel("https://raw.githubusercontent.com/Ironbeast917/collaborationenginetesting/refs/heads/main/Map.glb", true, NewVector3(0, 0, 0), NewQuaternion(0, 0, 0, 0), nil)

    entity = EntitySpawner.SpawnEntity(NewVector3(10, 0, 10), NewQuaternion(0, 0, 0, 0))
end

function FixedUpdate()
    entity.GameObject.Transform.Position = entity.GameObject.Transform.Position + NewVector3(0, 0, 1)
end
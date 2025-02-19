function Start()
    ModelSpawner.SpawnModel("https://raw.githubusercontent.com/Ironbeast917/collaborationenginetesting/refs/heads/main/Map.glb", true, NewVector3(0, 0, 0), NewQuaternion(0, 0, 0, 0), nil)

    entity = EntitySpawner.SpawnEntity(NewVector3(10, 0, 10), NewQuaternion(0, 0, 0, 0))
    entity.GameObject.AddComponent("https://raw.githubusercontent.com/Ironbeast917/collaborationenginetesting/refs/heads/main/entity.lua")
    ModelSpawner.SpawnModel("https://raw.githubusercontent.com/Ironbeast917/collaborationenginetesting/refs/heads/main/KNN.glb", false, entity.GameObject.Transform)
end